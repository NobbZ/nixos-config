{
  nobbz.homeManagerModules = {
    "profiles" = ./profiles;
    "profiles/base" = ./profiles/base;
    "profiles/browsing" = ./profiles/browsing;
    "profiles/development" = ./profiles/development;

    "languages" = ./languages;
    "languages/nix" = ./languages/nix;

    "programs/advcp" = ./programs/advcp;
    "programs/emacs" = ./programs/emacs;
    "programs/emacs/beacon" = ./programs/emacs/beacon.nix;
    "programs/emacs/company" = ./programs/emacs/company.nix;
    "programs/emacs/helm" = ./programs/emacs/helm.nix;
    "programs/emacs/lib" = ./programs/emacs/lib.nix;
    "programs/emacs/lsp" = ./programs/emacs/lsp.nix;
    "programs/emacs/projectile" = ./programs/emacs/projectile.nix;
    "programs/emacs/telephoneline" = ./programs/emacs/telephoneline.nix;
    "programs/emacs/whichkey" = ./programs/emacs/whichkey;
    "programs/eza" = ./programs/eza;
    "programs/nixpkgs" = ./programs/nixpkgs;
    "programs/openshift" = ./programs/openshift;
    "programs/p10k" = ./programs/p10k;

    "services/insync" = ./services/insync;
    "services/restic" = ./services/restic;
    "services/rustic" = ./services/rustic;

    "misc/awesome" = ./misc/awesome;
    "misc/home" = ./misc/home;
    "misc/rofi" = ./misc/rofi;
  };
}
