{ config, pkgs, ... }:

{
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bat.enable = true;
    direnv.enable = true;
    go.enable = true;
    jq.enable = true;

    irssi = { enable = true; };

    tmux = {
      enable = true;

      clock24 = true;
      historyLimit = 10000;
      terminal = "screen-256color";
    };
  };

#  services = { lorri.enable = true; };

  manual.html.enable = true;

  home.packages = with pkgs; [
    cachix
    nix-prefetch-scripts
    nix-review
    nixfmt
    nixops
  ];
}
