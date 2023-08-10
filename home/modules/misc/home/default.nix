{
  nixpkgs-2211,
  unstable,
  self,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  self' = self.packages.${pkgs.system};
in {
  _file = ./default.nix;

  profiles.base.enable = true;
  fonts.fontconfig.enable = true;

  systemd.user = {
    # sessionVariables = { NIX_PATH = nixPath; };
  };

  xsession.windowManager.awesome.enable = true;

  home = {
    # sessionVariables = { NIX_PATH = nixPath; };

    packages = let
      p = pkgs;
      s = self';
    in [
      p.cachix
      p.exercism
      p.nheko
      p.tmate
      s."dracula/konsole"

      # There is a conflict with the ZSH completion plugin, installed by default
      # therefore we need to override here
      (lib.setPrio 0 p.nixpkgs-review)

      p.fira-code
      p.cascadia-code

      p.lefthook

      (p.writeShellScriptBin "timew" ''
        export TIMEWARRIORDB="${config.home.homeDirectory}/timmelzer@gmail.com/timewarrior"
        exec ${p.timewarrior}/bin/timew "$@"
      '')
    ];

    stateVersion = "20.09";
  };
}
