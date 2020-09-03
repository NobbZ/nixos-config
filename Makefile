DEBUG = 0

NIX_FILES = $(shell find . -name '*.nix' -type f)

ifneq (${DEBUG},0)
  HM_VERBOSE = -v
endif

build:
	nix-shell --run "home-manager ${HM_VERBOSE} build"

switch:
	nix-shell --run "home-manager ${HM_VERBOSE} switch"

news:
	nix-shell --run "home-manager news"

format:
	nix-shell --run "nixpkgs-fmt ${NIX_FILES}"
