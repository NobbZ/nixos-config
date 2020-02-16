let sources = import ./sources.nix { };

in [
  (self: super: { inherit sources; })
  (self: super: {
    nixfmt = super.callPackage sources.nixfmt.outPath { installOnly = true; };
  })
  (import sources.emacs-overlay.outPath)
  (import ./myOverlay)
]
