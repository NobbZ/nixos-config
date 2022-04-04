use futures::future;
use std::{error::Error, fmt::Display, io::Error as IoError, path::Path, process::ExitStatus, str};
use tokio::{self, process::Command};

const OWNER: &str = "nobbz";
const REPO: &str = "nixos-config";

const BRANCH: &str = "main";

async fn get_command_out(cmd: &mut Command) -> String {
    let out = cmd.output().await.unwrap().stdout;

    str::from_utf8(&out).unwrap().trim().to_string()
}

async fn spawn_command(cmd: &mut Command) -> Result<ExitStatus, IoError> {
    cmd.spawn().unwrap().wait().await
}

async fn retrieve_sha<S1, S2, S3>(owner: S1, repo: S2, branch: S3) -> String
where
    S1: Display,
    S2: Display,
    S3: Display,
{
    let endpoint = format!("/repos/{}/{}/commits/{}", owner, repo, branch);

    get_command_out(Command::new("gh").args(["api", &endpoint, "--jq", ".sha"])).await
}

async fn get_hostname() -> String {
    get_command_out(&mut Command::new("hostname")).await
}

async fn get_username() -> String {
    get_command_out(&mut Command::new("whoami")).await
}

async fn get_tempfldr() -> String {
    get_command_out(&mut Command::new("mktemp").arg("-d")).await
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let sha1_promise = retrieve_sha(OWNER, REPO, BRANCH);
    let host_promise = get_hostname();
    let user_promise = get_username();
    let temp_promise = get_tempfldr();

    let (sha1, host, user, temp) =
        future::join4(sha1_promise, host_promise, user_promise, temp_promise).await;

    let flake_url = format!("github:{}/{}?ref={}", OWNER, REPO, sha1);
    let nixos_config = format!("{}#nixos/config/{}", flake_url, host);
    let nixos_rebuild = format!("{}#{}", flake_url, host);
    let home_config = format!("{}#home/config/{}@{}", flake_url, user, host);
    let home_manager = format!("{}#{}@{}", flake_url, user, host);
    let out_link = Path::new(&temp).join("result");

    spawn_command(Command::new("nix").args([
        "build",
        "--keep-going",
        "-L",
        "--out-link",
        &out_link.as_os_str().to_str().unwrap(),
        &nixos_config,
        &home_config,
    ]))
    .await?;

    spawn_command(Command::new("sudo").args([
        "nixos-rebuild",
        "switch",
        "--flake",
        &nixos_rebuild,
    ]))
    .await?;

    spawn_command(Command::new("home-manager").args(["switch", "--flake", &home_manager])).await?;

    spawn_command(Command::new("rm").args(["-rfv", &temp])).await?;

    Ok(())
}
