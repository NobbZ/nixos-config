let
  compat = import (builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/99f1c21.tar.gz");

  self = (compat { src = ./.; }).defaultNix;

  overlay = self.overlay;
  overlays = self.overlays;
in
[
  overlay
  overlays.inputs
  overlays.emacs
]
