{self,...}:
{pkgs,lib,...}:
{
  nixpkgs.allowedUnfree = [];

  activeProfiles = [];
  enabledLanguages = [];

  xsession.enable = lib.mkForce false;
  xsession.windowManager.awesome.enable = lib.mkForce false;
  xsession.numlock.enable = lib.mkForce false;

  gtk.theme.package = lib.mkForce null;

  home.packages = builtins.attrValues {
    inherit (pkgs) neovim;
  };
}
