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

  "programs/advcp" = import ./programs/advcp;
  "programs/emacs" = import ./programs/emacs;
  "programs/openshift" = import ./programs/openshift;
  "programs/zshell" = import ./programs/zshell;

  "services/keyleds" = import ./services/keyleds;

  "misc/awesome" = import ./misc/awesome;
}
