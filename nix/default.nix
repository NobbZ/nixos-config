let sources = import ./sources.nix { };

in
[
  (_: _: { inherit sources; })
  (import sources.mozilla-overlay.outPath)
  (import sources.emacs-overlay.outPath)
  (import ./myOverlay)
]
