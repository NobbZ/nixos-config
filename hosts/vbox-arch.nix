{ pkgs, ... }:

{
  config = {
    home.packages = [ ];
    profiles.development.enable = true;
  };
}
