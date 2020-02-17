{ pkgs, ... }:

{
  config = {
    home.packages = [ ];
    profiles.development.enable = true;
    programs.zsh.enable = true;
    programs.zsh.localVariables = {
      FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
    };
  };
}
