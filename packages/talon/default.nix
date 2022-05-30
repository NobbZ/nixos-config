# This derivation was found on the internet and slightly adjusted to match todays
# attribute names for dependencies.
#
# Be aware that it will randomly fail to build, which might happen without me
# actually noticing it. This will be the case whenever upstream releases an
# update and therefore the `sha256` doesn't match anymore.
{
  stdenv,
  lib,
  requireFile,
  makeWrapper,
  dbus,
  fontconfig,
  freetype,
  glib,
  libGL,
  libxkbcommon_7,
  sqlite,
  udev,
  xorg,
  zlib,
  fetchurl,
  libpulseaudio,
  bzip2,
  ncurses5,
  gdk-pixbuf,
  libuuid,
  libdrm,
  gtk3-x11,
  cairo,
  gdbm,
  gnome2,
  atk,
  libsForQt5,
  wayland,
  wayland-protocols,
  wlroots,
  xwayland,
  libinput,
  libxml2,
}:
stdenv.mkDerivation rec {
  pname = "talon";
  version = "latest";
  src = fetchTarball {
    url = "https://talonvoice.com/dl/latest/talon-linux.tar.xz";
    sha256 = "sha256:0kpfyk1i68cs9y0jbry2mn1299l8zzgmfq0nn40c9vyxn2lmnycl";
  };
  preferLocalBuild = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc
    stdenv.cc.libc
    dbus
    fontconfig
    freetype
    glib
    libGL
    libxkbcommon_7
    sqlite
    zlib
    libpulseaudio
    udev
    xorg.libX11
    xorg.libSM
    xorg.libXcursor
    xorg.libICE
    xorg.libXrender
    xorg.libxcb
    xorg.libXext
    xorg.libXcomposite
    bzip2
    ncurses5
    libuuid
    gtk3-x11
    gdk-pixbuf
    cairo
    libdrm
    gnome2.pango
    gdbm
    atk
    wayland
    wayland-protocols
    wlroots
    xwayland
    libinput
    libxml2
  ];

  phases = ["unpackPhase" "installPhase"];

  installPhase = let
    libPath = lib.makeLibraryPath buildInputs;
  in ''
    runHook preInstall
    # Copy Talon to the Nix store
    mkdir -p "$out"
    mkdir "$out/bin"
    mkdir -p "$out/etc/udev/rules.d"
    mkdir -p $out/share/applications
    cat << EOF > $out/share/applications/talon.desktop
      [Desktop Entry]
      Categories=Utility;
      Exec=talon
      Name=Talon
      Terminal=false
      Type=Application
    EOF
    cp 10-talon.rules $out/etc/udev/rules.d
    cp -r lib $out/lib
    cp talon $out/bin
    cp -r resources $out/bin/resources
    # Delete because messes up ldd missing deps detection
    rm $out/bin/resources/python/lib/python3.9/site-packages/torch/bin/test_tensorexpr
    # Tell talon where to find glibc
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/bin/talon
    # Replicate 'run.sh' and add library path
    wrapProgram "$out/bin/talon" \
      --unset QT_AUTO_SCREEN_SCALE_FACTOR \
      --unset QT_SCALE_FACTOR \
      --set   LC_NUMERIC C \
      --set   QT_PLUGIN_PATH "$out/lib/plugins" \
      --set   LD_LIBRARY_PATH "$out/lib:$out/bin/resources/python/lib:$out/bin/resources/pypy/lib:${libPath}" \
      --set   QT_DEBUG_PLUGINS 1
    # This will fix the talon repl
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/bin/resources/python/bin/python3
    wrapProgram "$out/bin/resources/python/bin/python3" \
      --set LD_LIBRARY_PATH ${libPath}
    # The libbz2 derivation in Nix doesn't provide the right .so filename, so
    # we fake it by adding a link in the lib/ directory
    (
      cd "$out/lib"
      ln -s ${bzip2.out}/lib/libbz2.so.1 libbz2.so.1.0
      ln -s ${gdbm}/lib/libgdbm.so libgdbm.so.5
    )
    runHook postInstall
  '';
}
