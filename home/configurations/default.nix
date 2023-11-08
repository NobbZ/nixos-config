_: {
  _file = ./default.nix;

  nobbz.homeConfigurations."nmelzer@mimas".system = "x86_64-linux";
  nobbz.homeConfigurations."nmelzer@enceladeus".system = "x86_64-linux";
  nobbz.homeConfigurations."nmelzer@hyperion".system = "aarch64-linux";
  nobbz.homeConfigurations."nmelzer@janus".system = "x86_64-linux";
  nobbz.homeConfigurations."nmelzer@phoebe".system = "x86_64-linux";

  nobbz.homeConfigurations."nmelzer@Titan.local" = {
    system = "aarch64-darwin";
    hostname = "titan";
  };
}
