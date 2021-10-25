{
  "profiles" = import ./profiles;
  "profiles/base" = import ./profiles/base;
  "profiles/browsing" = import ./profiles/browsing;
  "profiles/development" = import ./profiles/development;
  "profiles/home-office" = import ./profiles/home-office;

  "languages" = import ./languages;
  "languages/agda" = import ./languages/agda;
  "languages/c++" = import ./languages/c++;
  "languages/clojure" = import ./languages/clojure;
  "languages/elixir" = import ./languages/elixir;
  "languages/erlang" = import ./languages/erlang;
  "languages/go" = import ./languages/go;
  "languages/nix" = import ./languages/nix;
  "languages/python" = import ./languages/python;
  "languages/rust" = import ./languages/rust;
  "languages/tex" = import ./languages/tex;
  "languages/lua" = import ./languages/lua;
  "languages/terraform" = import ./languages/terraform;

  "programs/advcp" = import ./programs/advcp;
  "programs/openshift" = import ./programs/openshift;
  "programs/zshell" = import ./programs/zshell;
  "programs/nixpkgs" = import ./programs/nixpkgs;
  "programs/exa" = import ./programs/exa;
  "programs/emacs" = import ./programs/emacs;
  "programs/emacs/beacon" = import ./programs/emacs/beacon.nix;
  "programs/emacs/company" = import ./programs/emacs/company.nix;
  "programs/emacs/helm" = import ./programs/emacs/helm.nix;
  "programs/emacs/lsp" = import ./programs/emacs/lsp.nix;
  "programs/emacs/projectile" = import ./programs/emacs/projectile.nix;
  "programs/emacs/telephoneline" = import ./programs/emacs/telephoneline.nix;
  "programs/emacs/lib" = import ./programs/emacs/lib.nix;
  "programs/emacs/whichkey" = import ./programs/emacs/whichkey;

  "services/keyleds" = import ./services/keyleds;
  "services/insync" = import ./services/insync;
  "services/restic" = import ./services/restic;

  "misc/awesome" = import ./misc/awesome;
  "misc/home" = import ./misc/home;
}
