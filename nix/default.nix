let sources = import ./sources.nix { };

in
[
  (self: super: { inherit sources; })
  (import sources.nixpkgs-mozilla.outPath)
  (import sources.emacs-overlay.outPath)
  (import ./myOverlay)
]
