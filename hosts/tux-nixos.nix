{ pkgs, ... }:

{
  config = {
    home.packages = [ pkgs.hydra ];

    services.keyleds.enable = true;
  };
}
