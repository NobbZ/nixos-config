let sources = import ./sources.nix { };

in [
  (self: super: { inherit sources; })
  (self: super: {
    nixfmt = super.callPackage sources.nixfmt.outPath { installOnly = true; };
  })
  (import sources.nixpkgs-mozilla.outPath)
  (import sources.emacs-overlay.outPath)
  (import ./myOverlay)
]
