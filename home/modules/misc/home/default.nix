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
    packages =
      [
        # There is a conflict with the ZSH completion plugin, installed by default
        # therefore we need to override here
        (lib.setPrio 0 pkgs.nixpkgs-review)
      ]
      ++ (builtins.attrValues {
        inherit (pkgs.nerd-fonts) symbols-only;
        inherit (pkgs) annextimelog;
      });
  };
}
