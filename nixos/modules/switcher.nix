{self, ...}: {
  pkgs,
  config,
  ...
}: {
  _file = ./switcher.nix;

  environment.systemPackages = [self.packages."${pkgs.system}".switcher];

  security.sudo.extraRules = let
    storePrefix = "/nix/store/*";
    commandPrefix = "/run/current-system/sw";
    systemName = "nixos-system-${config.networking.hostName}-*";
    nixEnvCmd = "${commandPrefix}/bin/nix-env";
    systemdPath = "${commandPrefix}/bin/systemd-run";
    systemdRunCmd = "${systemdPath} -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER --collect --no-ask-password --pty --quiet --same-dir --service-type=exec --unit=nixos-rebuild-switch-to-configuration";
    options = ["NOPASSWD"];
    mkRule = command: {
      commands = [{inherit command options;}];
      groups = ["wheel"];
    };
  in [
    (mkRule "${nixEnvCmd} -p /nix/var/nix/profiles/system --set ${storePrefix}-${systemName}")
    (mkRule "${systemdRunCmd} --wait true")
    (mkRule "${systemdRunCmd} --wait ${storePrefix}-${systemName}/bin/switch-to-configuration switch")
  ];
}
