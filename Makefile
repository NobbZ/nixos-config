DEBUG = 0
LOCAL = 0

HOSTNAME = $(shell hostname)

OPTIONS =

NIX_FILES = $(shell find . -name '*.nix' -type f)

ifneq (${DEBUG},0)
  HM_VERBOSE = -v
endif

ifneq ($(LOCAL),0)
  OPTIONS += --option builders ''
endif

build:
	ln -s $(HOSTNAME).nix hosts/default.nix
	nix-shell --run "home-manager ${HM_VERBOSE} $(OPTIONS) build"
	rm hosts/default.nix

switch:
	ln -s $(HOSTNAME).nix hosts/default.nix
	nix-shell --run "home-manager ${HM_VERBOSE} $(OPTIONS) switch"
	rm hosts/default.nix

update:
	nix-shell --run "niv update"

news:
	nix-shell --run "home-manager news"

format:
	nix-shell --run "nixpkgs-fmt ${NIX_FILES}"

clean:
	rm -rfv result
	rm -rfv hosts/default.nix
