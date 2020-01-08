{ ... }:

let pkgs = import ./nix { };

in {
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bat.enable = true;
    direnv.enable = true;
    go.enable = true;
    jq.enable = true;

    irssi = {
      enable = true;
      networks = {
        freenode = {
          nick = "NobbZ";
          server = {
            address = "chat.freenode.net";
            port = 6697;
            autoConnect = true;
          };
          channels = {
            nixos.autoJoin = true;
            home-manager.autoJoin = true;
          };
        };
      };
    };

    tmux = {
      enable = true;

      clock24 = true;
      historyLimit = 10000;
      terminal = "screen-256color";
    };
  };

  # services = { lorri.enable = true; };

  manual.html.enable = true;

  home.file = {
    ".zsh/boot/asdf.zsh" = {
      text = ''
        . ${pkgs.asdfVm}/asdf.sh
        . ${pkgs.asdfVm}/completions/asdf.bash
      '';
    };
  };

  home.packages = with pkgs; [
    asdfVm
    # cachix
    niv
    nix-prefetch-scripts
    nix-review
    nixfmt
    nixops
  ];
}
