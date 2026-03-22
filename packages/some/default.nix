{
  stdenv,
  sources,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  libdrm,
  libinput,
  libxkbcommon,
  linux-pam,
  lua,
  makeWrapper,
  meson,
  ninja,
  pango,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
  which,
  wlroots,
  xorg,
  librsvg,
  extraLuaPackages ? (_: []),
}: let
  luaEnv = lua.withPackages (lp:
    [
      lp.lgi
    ]
    ++ (extraLuaPackages lp));
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "somewm";
    version = sources.somewm.version or sources.somewm.revision;

    src = sources.somewm;

    nativeBuildInputs = [
      meson
      pkg-config
      makeWrapper
      gobject-introspection
      ninja
    ];

    buildInputs = [
      linux-pam
      cairo
      dbus
      gdk-pixbuf
      wlroots
      wayland-scanner
      glib
      libdrm
      libinput
      libxkbcommon
      lua
      luaEnv
      pango
      wayland
      wayland-protocols
      xorg.xcbutilwm
      xorg.xcbutil
      librsvg
    ];

    env = {
      LUA_CPATH = "${luaEnv}/lib/lua/${lua.luaversion}/?.so";
      LUA_PATH = "${luaEnv}/share/lua/${lua.luaversion}/?.lua;;";
    };

    postInstall = ''
      # Don't use wrapProgram or the wrapper will duplicate the --search
      # arguments every restart
      mv "$out/bin/somewm" "$out/bin/.somewm-wrapped"
      makeWrapper "$out/bin/.somewm-wrapped" "$out/bin/somewm" \
        --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
        --add-flags '--search ${luaEnv}/lib/lua/${lua.luaversion}' \
        --add-flags '--search ${luaEnv}/share/lua/${lua.luaversion}' \
        --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH"

      wrapProgram $out/bin/somewm-client \
        --prefix PATH : "${which}/bin"
    '';
  })
