DEBUG = 0
LOCAL = 0

HOSTNAME = $(shell hostname)

OPTIONS =

NIX_FILES = $(shell find . -name '*.nix' -type f)

## Versions
ELIXIR_LS_VSN = 0.6.5
ERLANG_LS_VSN = 0.11.0

ifneq (${DEBUG},0)
  HM_VERBOSE = -v
endif

ifneq ($(LOCAL),0)
  OPTIONS += --option builders ''
endif

build:
	ln -fs $(HOSTNAME).nix hosts/default.nix
	nix-shell --run "home-manager ${HM_VERBOSE} $(OPTIONS) build"
	rm hosts/default.nix

switch:
	ln -fs $(HOSTNAME).nix hosts/default.nix
	nix-shell --run "home-manager ${HM_VERBOSE} $(OPTIONS) switch"
	rm hosts/default.nix

update:
	nix-shell --run "niv update"

update_elixir_ls:
	nix shell nixpkgs/nixos-unstable#nix-prefetch-github -c nix-prefetch-github --rev v$(ELIXIR_LS_VSN) elixir-lsp elixir-ls | jq '. + {version: "$(ELIXIR_LS_VSN)"}' > packages/elixir-lsp/source.json

update_erlang_ls:
	nix shell nixpkgs/nixos-unstable#nix-prefetch-github -c nix-prefetch-github --rev $(ERLANG_LS_VSN) erlang-ls erlang_ls | jq '. + {version: "$(ERLANG_LS_VSN)"}' > packages/erlang-ls/source.json

update_emoji:
	nix-shell --run "nix-prefetch-git https://git.teknik.io/matf/rofiemoji-rofiunicode.git > packages/rofi-unicode/rofi-unicode.json"

news:
	nix-shell --run "home-manager news"

format:
	nix-shell --run "nixpkgs-fmt ${NIX_FILES}"

clean:
	rm -rfv result
	rm -rfv hosts/default.nix
