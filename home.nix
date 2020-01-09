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
        if which asdfloader 2>&1 >/dev/null; then
          eval $(asdfloader)
        fi
      '';
    };
    ".zsh/boot/exa.zsh" = {
      text = ''
        alias ll="exa --header --git --classify --long --binary --group --time-style=long-iso --links --all --all --group-directories-first --sort=name"
      '';
    };
  };

  home.packages = with pkgs; [
    antora
    asciidoctor
    asdf-vm
    # cachix
    exa
    niv
    nix-prefetch-scripts
    nix-review
    nixfmt
    nixops
  ];
}
