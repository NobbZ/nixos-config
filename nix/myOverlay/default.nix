self: super:

{
  advcp = super.callPackage (import ./advcp) { };
  asdf-vm = super.callPackage (import ./asdf) { };
  aur-tools = super.callPackage (import ./aur) { };
  keyleds = super.callPackage (import ./keyleds) { };
}
