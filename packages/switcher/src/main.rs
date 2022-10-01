use futures::future;
use std::{
    error::Error,
    io::Error as IoError,
    path::Path,
    process::{ExitStatus, Stdio},
    str,
};
use tokio::{self, process::Command};
use tracing::{instrument, Level};
use tracing_futures::Instrument;
use tracing_subscriber::FmtSubscriber;

mod github;

const OWNER: &str = "nobbz";
const REPO: &str = "nixos-config";

const BRANCH: &str = "main";

#[instrument]
async fn get_command_out(cmd: &mut Command) -> String {
    let out = cmd.output().await.unwrap().stdout;

    str::from_utf8(&out).unwrap().trim().to_string()
}

#[instrument]
async fn spawn_command(cmd: &mut Command) -> Result<ExitStatus, IoError> {
    cmd.spawn().unwrap().wait().await
}

#[instrument]
async fn retrieve_sha(owner: &str, repo: &str, branch: &str) -> String {
    github::get_latest_commit(owner, repo, branch)
        .await
        .unwrap()
}

#[instrument]
async fn get_hostname() -> String {
    get_command_out(&mut Command::new("hostname")).await
}

#[instrument]
async fn get_username() -> String {
    get_command_out(&mut Command::new("whoami")).await
}

#[instrument]
async fn get_tempfldr() -> String {
    get_command_out(Command::new("mktemp").arg("-d")).await
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    FmtSubscriber::builder().with_max_level(Level::DEBUG).init();

    tracing::info!("Gathering info");

    let sha1_promise = retrieve_sha(OWNER, REPO, BRANCH);
    let host_promise = get_hostname();
    let user_promise = get_username();
    let temp_promise = get_tempfldr();

    let (sha1, host, user, temp) =
        future::join4(sha1_promise, host_promise, user_promise, temp_promise)
            .instrument(tracing::trace_span!("join4"))
            .await;

    tracing::info!(%sha1, %host, %user, %temp, "Gathered info");
    tracing::info!("Building strings");

    let flake_url = format!("github:{}/{}?ref={}", OWNER, REPO, sha1);
    let nixos_config = format!("{}#nixos/config/{}", flake_url, host);
    let nixos_rebuild = format!("{}#{}", flake_url, host);
    let home_config = format!("{}#home/config/{}@{}", flake_url, user, host);
    let home_manager = format!("{}#{}@{}", flake_url, user, host);
    let out_link = Path::new(&temp).join("result");

    tracing::info!(%flake_url, %nixos_config, %nixos_rebuild, %home_config, %home_manager, ?out_link, "Built strings");
    tracing::info!("Starting to build");

    spawn_command(
        Command::new("bash").arg("-c").arg(
            [
                "nix",
                "build",
                "--keep-going",
                "-L",
                "--out-link",
                out_link.as_os_str().to_str().unwrap(),
                &nixos_config,
                &home_config,
                "|&",
                "nom",
            ]
            .join(" "),
        ),
    )
    .await?;

    tracing::info!("Finished building");
    tracing::info!(%host, "Switching system configuration");

    spawn_command(Command::new("sudo").args([
        "nixos-rebuild",
        "switch",
        "--flake",
        &nixos_rebuild,
    ]))
    .await?;

    tracing::info!(%host, "Switched system configuration");
    tracing::info!(%user, %host, "Switching user configuration");

    spawn_command(Command::new("home-manager").args(["switch", "--flake", &home_manager])).await?;

    tracing::info!(%user, %host, "Switched user configuration");
    tracing::info!(%temp, "Cleaning up");

    spawn_command(Command::new("rm").args(["-rfv", &temp])).await?;

    Ok(())
}
