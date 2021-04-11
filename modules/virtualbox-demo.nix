{ modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/virtualbox-demo.nix") ];
}
