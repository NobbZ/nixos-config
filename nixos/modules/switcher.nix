{self, ...}: {pkgs, ...}: {
  environment.systemPackages = [self.packages."${pkgs.system}".switcher];
}
