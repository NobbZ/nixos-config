{
  unstable,
  self,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    nixpkgs.allowedUnfree = ["vscode"];
    # nixpkgs.config.allowBroken = true;

    activeProfiles = ["development"];

    dconf.enable = true;

    enabledLanguages = [];

    xsession.enable = lib.mkForce false;
    xsession.windowManager.awesome.enable = lib.mkForce false;
    xsession.numlock.enable = lib.mkForce false;

    programs.emacs.splashScreen = false;

    home.packages = builtins.attrValues {
      inherit (pkgs) handbrake vscode keepassxc nix-output-monitor;
      inherit (pkgs.gnome) gnome-tweaks;
      inherit (self.packages.aarch64-linux) gnucash-de;
    };

    programs.htop = {
      settings = {
        detailed_cpu_time = true;
      };
    };
  };
  # environment.pathsToLink = [ "/share/zsh" ];
}
# /nix/store/7skqa8vxfydq7w3cix55ffvkmjb3b5da-python-2.7.18

