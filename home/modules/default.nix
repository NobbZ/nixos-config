inputs: {
  "profiles" = import ./profiles inputs;
  "profiles/base" = import ./profiles/base inputs;
  "profiles/browsing" = import ./profiles/browsing inputs;
  "profiles/development" = import ./profiles/development inputs;

  "languages" = import ./languages inputs;
  "languages/nix" = import ./languages/nix inputs;

  "programs/advcp" = import ./programs/advcp inputs;
  "programs/emacs" = import ./programs/emacs inputs;
  "programs/emacs/beacon" = import ./programs/emacs/beacon.nix inputs;
  "programs/emacs/company" = import ./programs/emacs/company.nix inputs;
  "programs/emacs/helm" = import ./programs/emacs/helm.nix inputs;
  "programs/emacs/lib" = import ./programs/emacs/lib.nix inputs;
  "programs/emacs/lsp" = import ./programs/emacs/lsp.nix inputs;
  "programs/emacs/projectile" = import ./programs/emacs/projectile.nix inputs;
  "programs/emacs/telephoneline" = import ./programs/emacs/telephoneline.nix inputs;
  "programs/emacs/whichkey" = import ./programs/emacs/whichkey inputs;
  "programs/exa" = import ./programs/exa inputs;
  "programs/nixpkgs" = import ./programs/nixpkgs inputs;
  "programs/openshift" = import ./programs/openshift inputs;
  "programs/p10k" = import ./programs/p10k inputs;

  "services/insync" = import ./services/insync inputs;
  "services/restic" = import ./services/restic inputs;
  "services/rustic" = import ./services/rustic inputs;

  "misc/awesome" = import ./misc/awesome inputs;
  "misc/home" = import ./misc/home inputs;
  "misc/rofi" = import ./misc/rofi inputs;
}
