{ config, lib, pkgs, ... }:
let
  cfg = config.languages;

  langsEnabler =
    let reducer = l: r: { "${r}".enable = true; } // l;
    in builtins.foldl' reducer { } config.enabledLanguages;

in
{
  imports = [
    ./agda
    ./c
    ./c++
    ./clojure
    ./elixir
    ./erlang
    ./go
    ./lua
    ./ocaml
    ./python
    ./rust
    ./nix
    ./terraform
  ];

  options.enabledLanguages =
    lib.mkOption { type = lib.types.listOf lib.types.str; };

  config = { languages = langsEnabler; };
}
