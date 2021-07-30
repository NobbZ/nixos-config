inputs:

{
  mkSystem = import ./mk_system.nix inputs;
  nixosConfigurationsAsPackages = import ./nixos_configurations_as_packages.nix inputs;
  homeConfigurationsAsPackages = import ./home_configurations_as_packages.nix inputs;
}
