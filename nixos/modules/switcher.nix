{switcher, ...}: {pkgs, ...}: {
  environment.systemPackages = [switcher.packages."${pkgs.system}".switcher];
}
