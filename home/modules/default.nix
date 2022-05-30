inputs: {
  "profiles" = import ./profiles inputs;
  "profiles/base" = import ./profiles/base inputs;
  "profiles/browsing" = import ./profiles/browsing inputs;
  "profiles/development" = import ./profiles/development inputs;

  "languages" = import ./languages inputs;
  "languages/agda" = import ./languages/agda inputs;
  "languages/c++" = import ./languages/c++ inputs;
  "languages/clojure" = import ./languages/clojure inputs;
  "languages/elixir" = import ./languages/elixir inputs;
  "languages/erlang" = import ./languages/erlang inputs;
  "languages/go" = import ./languages/go inputs;
  "languages/nim" = import ./languages/nim inputs;
  "languages/nix" = import ./languages/nix inputs;
  "languages/python" = import ./languages/python inputs;
  "languages/rust" = import ./languages/rust inputs;
  "languages/tex" = import ./languages/tex inputs;
  "languages/lua" = import ./languages/lua inputs;
  "languages/terraform" = import ./languages/terraform inputs;

  "programs/advcp" = import ./programs/advcp inputs;
  "programs/openshift" = import ./programs/openshift inputs;
  "programs/zshell" = import ./programs/zshell inputs;
  "programs/nixpkgs" = import ./programs/nixpkgs inputs;
  "programs/exa" = import ./programs/exa inputs;
  "programs/emacs" = import ./programs/emacs inputs;
  "programs/emacs/beacon" = import ./programs/emacs/beacon.nix inputs;
  "programs/emacs/company" = import ./programs/emacs/company.nix inputs;
  "programs/emacs/helm" = import ./programs/emacs/helm.nix inputs;
  "programs/emacs/lsp" = import ./programs/emacs/lsp.nix inputs;
  "programs/emacs/projectile" = import ./programs/emacs/projectile.nix inputs;
  "programs/emacs/telephoneline" = import ./programs/emacs/telephoneline.nix inputs;
  "programs/emacs/lib" = import ./programs/emacs/lib.nix inputs;
  "programs/emacs/whichkey" = import ./programs/emacs/whichkey inputs;

  "services/keyleds" = import ./services/keyleds inputs;
  "services/insync" = import ./services/insync inputs;
  "services/restic" = import ./services/restic inputs;

  "misc/awesome" = import ./misc/awesome inputs;
  "misc/home" = import ./misc/home inputs;

  "talon" = import ./talon.nix inputs;
}
