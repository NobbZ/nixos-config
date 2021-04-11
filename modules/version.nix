{ self, ... }:
{
  system.configurationRevision = self.rev or "dirty";
}
