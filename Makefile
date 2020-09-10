DEBUG = 0
LOCAL = 0

OPTIONS =

NIX_FILES = $(shell find . -name '*.nix' -type f)

ifneq (${DEBUG},0)
  HM_VERBOSE = -v
endif

ifneq ($(LOCAL),0)
  OPTIONS += --option builders ''
endif

build:
	nix-shell --run "home-manager ${HM_VERBOSE} $(OPTIONS) build"

switch:
	nix-shell --run "home-manager ${HM_VERBOSE} $(OPTIONS) switch"

news:
	nix-shell --run "home-manager news"

format:
	nix-shell --run "nixpkgs-fmt ${NIX_FILES}"
