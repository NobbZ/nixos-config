{ pkgs, ... }:

{
  config = {
    home.packages = [ pkgs.fira-code ];
    profiles.development.enable = true;
    programs.zsh.enable = true;
    home.sessionVariables = {
      FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
    };
  };
}
