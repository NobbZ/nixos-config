self: super:

{
  asdf-vm = super.callPackage (import ./asdf) { };
}
