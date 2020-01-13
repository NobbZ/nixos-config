let sources = import ./sources.nix { };

in [ (_: pkgs: { inherit sources; }) (import ./asdf-vm.nix) ]
