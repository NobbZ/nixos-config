{ sources, srcOnly, fetchFromGitHub, ... }:

srcOnly rec {
  name = "direnv-nix";

  src = sources.nix-direnv;
}
