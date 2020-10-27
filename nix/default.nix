let sources = import ./sources.nix { };

in
[
  (self: super: { inherit sources; })
  (import sources.mozilla-overlay.outPath)
  (import sources.emacs-overlay.outPath)
  (import ./myOverlay)
]
