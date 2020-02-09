{ pkgs, ... }:

{
  config = { home.packages = [ pkgs.hydra ]; };
}
