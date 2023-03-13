{self, ...}: {
  pkgs,
  config,
  ...
}: {
  _file = ./switcher.nix;

  environment.systemPackages = [self.packages."${pkgs.system}".switcher];

  security.sudo.extraRules = let
    storePrefix = "/nix/store/*";
    systemName = "nixos-system-${config.networking.hostName}-*";
  in [
    {
      commands = [
        {
          command = "${storePrefix}-nix-*/bin/nix-env -p /nix/var/nix/profiles/system --set ${storePrefix}-${systemName}";
          options = ["NOPASSWD"];
        }
      ];
      groups = ["wheel"];
    }
    {
      commands = [
        {
          command = "${storePrefix}-${systemName}/bin/switch-to-configuration";
          options = ["NOPASSWD"];
        }
      ];
      groups = ["wheel"];
    }
  ];
}
