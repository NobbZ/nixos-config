DEBUG = 0
LOCAL = 0

HOSTNAME = $(shell hostname)

OPTIONS =

NIX_FILES = $(shell find . -name '*.nix' -type f)

## Versions
ELIXIR_LS_VSN = 0.6.0
ERLANG_LS_VSN = 0.5.1

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
	nix-shell --run "nix-prefetch-github --rev v$(ELIXIR_LS_VSN) elixir-lsp elixir-ls > nix/myOverlay/elixir-lsp/source.json"
	nix-shell --run "nix-prefetch-github --rev $(ERLANG_LS_VSN) erlang-ls erlang_ls > nix/myOverlay/erlang-ls/source.json"
	nix-shell --run "nix-prefetch-git https://git.teknik.io/matf/rofiemoji-rofiunicode.git > nix/myOverlay/rofi-unicode.json"

news:
	nix-shell --run "home-manager news"

format:
	nix-shell --run "nixpkgs-fmt ${NIX_FILES}"

clean:
	rm -rfv result
	rm -rfv hosts/default.nix
