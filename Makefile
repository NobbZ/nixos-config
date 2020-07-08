DEBUG = 0

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
	nix-shell --run "find . -name '*.nix' -type f -exec nixfmt '{}' \\;"
