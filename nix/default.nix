let sources = import ./sources.nix { };

in [
  (self: super: { inherit sources; })
  (import sources.emacs-overlay.outPath)
  (import ./myOverlay)
  (import ./keyleds)
]
