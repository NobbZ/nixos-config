package cicd

import "cue.dev/x/githubactions"

_nixVersion: "2.32.1"

workflows: [_]: githubactions.#Workflow & {
	jobs: [_]: "runs-on": *"ubuntu-24.04" | _
}

_cloneRepo: githubactions.#Step & {
	name: "Clone Repository"
	uses: "actions/checkout@v6"
	with: token: "${{ secrets.TEST_TOKEN }}"
}

_installCue: githubactions.#Step & {
	name: "Install Cue"
	uses: "cue-lang/setup-cue@v1.0.1"
	with: version: "v0.14.2"
}

_installNix: githubactions.#Step & {
	name: "Install nix"
	uses: "cachix/install-nix-action@v31"
	with: {
		extra_nix_config: """
			auto-optimise-store = true
			access-tokens = github.com=${{ secrets.TEST_TOKEN }}
			experimental-features = nix-command flakes
			substituters = https://cache.nixos.org/ https://nix-community.cachix.org
			trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
			"""
		install_url: "https://releases.nixos.org/nix/nix-\(_nixVersion)/install"
	}
}

_freeSpace: githubactions.#Step & {
	name: "Free diskspace"
	uses: "wimpysworld/nothing-but-nix@main"
}

_cachixBase: githubactions.#Step & {
	name: "Set up cachix"
	uses: "cachix/cachix-action@v16"
	with: {
		name:       "nobbz"
		signingKey: "${{ secrets.CACHIX_SIGNING_KEY }}"
	}
}

_cachixNoPush: _cachixBase & {
	with: {
		skipPush: true
	}
}

_cachix: _cachixBase & {
	with: {
		pathsToPush: "result"
	}
}

_restoreFlakeLock: githubactions.#Step & {
	name: "Restore flake.lock"
	uses: "actions/download-artifact@v7"
	with: name: "flake_lock"
}

_setupGit: githubactions.#Step & {
	name: "Setup git"
	run: """
		git config user.email gitbot@nobbz.dev
		git config user.name "Git Bot"
		"""
}

_buildFlake: githubactions.#Job & {
	_flakeLock!: bool
	needs: [
		"generate_matrix",
		if _flakeLock {"update_flake"},
	]
	strategy: {
		"fail-fast":    false
		"max-parallel": 5
		matrix: {
			package: "${{fromJson(needs.generate_matrix.outputs.packages)}}"
			exclude: [{package: "installer-iso"}]
		}
	}
	steps: [
		_freeSpace,
		_cloneRepo,
		_installNix,
		_cachix,
		if _flakeLock {_restoreFlakeLock},
		{
			name: "Build everything"
			run:  "nix build .#${{ matrix.package }}"
		},
	]
}

_buildChecks: githubactions.#Job & {
	_flakeLock!: bool
	needs: [
		"generate_matrix",
		if _flakeLock {"update_flake"},
	]
	strategy: {
		"fail-fast":    false
		"max-parallel": 5
		matrix: {
			check: "${{fromJson(needs.generate_matrix.outputs.checks)}}"
		}
	}
	steps: [
		_cloneRepo,
		_installNix,
		_cachixNoPush,
		if _flakeLock {_restoreFlakeLock},
		{
			name: "Build the check"
			run:  "nix build .#checks.x86_64-linux.${{ matrix.check }} --no-link"
		},
	]
}

_checkFlake: githubactions.#Job & {
	_flakeLock!: bool
	needs: [
		"generate_matrix",
		if _flakeLock {"update_flake"},
	]
	"continue-on-error": true
	steps: [
		_cloneRepo,
		_installNix,
		if _flakeLock {_restoreFlakeLock},
		{
			name: "Run generic check"
			run:  "nix flake check --keep-going"
		},
	]
}
