{
  nvim,
  pkgs,
  ...
}: {
  environment.variables.EDITOR = "nvim";

  environment.systemPackages = [nvim.packages.${pkgs.system}.neovim];
}
