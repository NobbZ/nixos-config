let sources = import ./sources.nix { };

in [ (self: super: { inherit sources; }) (import ./asdf-vm) (import ./aur) ]
