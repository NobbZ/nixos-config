{ config, lib, pkgs, ... }:
let
  cfg = config.programs.asdf-vm;
  files = [ "asdf.sh" "completions/asdf.bash" ];
  sources = builtins.map (f: "${pkgs.asdf-vm}/${f}") files;
in
{
  options.programs.asdf-vm = {
    enable = lib.mkEnableOption
      "Extendable version manager with support for Ruby, Node.js, Elixir, Erlang & more";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.asdf-vm ];

    programs.zshell.sources = sources;
  };
}
