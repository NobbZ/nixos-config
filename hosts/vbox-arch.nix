{ pkgs, ... }:

{
  config = {
    home.packages = [ pkgs.hydra ];
    profiles.development.enable = true;
  };
}
