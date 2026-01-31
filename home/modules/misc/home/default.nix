{self, ...}: {
  config,
  pkgs,
  lib,
  ...
}: {
  profiles.base.enable = true;
  fonts.fontconfig.enable = true;

  xsession.windowManager.awesome.enable = true;

  home = {
    packages = let
      p = pkgs;
    in [
      p.cachix
      p.exercism
      p.tmate

      # There is a conflict with the ZSH completion plugin, installed by default
      # therefore we need to override here
      (lib.setPrio 0 p.nixpkgs-review)

      p.fira-code
      p.cascadia-code
      p.nerd-fonts.symbols-only

      p.annextimelog
    ];
  };
}
