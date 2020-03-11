self: super:

{
  advcp = super.callPackage (import ./advcp) { };
  asdf-vm = super.callPackage (import ./asdf) { };
  aur-tools = super.callPackage (import ./aur) { };
  elixir-lsp = super.callPackage (import ./elixir-lsp) { };
  keyleds = super.callPackage (import ./keyleds) { };

  nobbzLib = (import ./lib);
}
