{ config, lib, pkgs, ... }:

let
  cfg = config.programs.asdf-vm;
in
{
  options.programs.asdf-vm = {
    enable = lib.mkEnableOption "Extendable version manager with support for Ruby, Node.js, Elixir, Erlang & more";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.asdf-vm
    ];

    home.file = {
      ".zsh/boot/asdf.zsh" = {
        text = ''
          . "${pkgs.asdf-vm}/asdf.sh"
          . "${pkgs.asdf-vm}/completions/asdf.bash"
        '';
      };
    };
  };
}
