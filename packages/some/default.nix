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
  librsvg,
  libxcb-util,
  libxcb-wm,
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
      cairo
      dbus
      gdk-pixbuf
      glib
      libdrm
      libinput
      librsvg
      libxcb-util
      libxcb-wm
      libxkbcommon
      linux-pam
      lua
      luaEnv
      pango
      wayland
      wayland-protocols
      wayland-scanner
      wlroots
    ];

    env = {
      LUA_CPATH = "${luaEnv}/lib/lua/${lua.luaversion}/?.so";
      LUA_PATH = "${luaEnv}/share/lua/${lua.luaversion}/?.lua;;";
    };

    prePatch = ''
      # if not patched, meson will try to install the user-unit into the systemd
      # store path.
      substituteInPlace meson.build \
        --replace-fail "systemd_user_unit_dir = systemd_dep.get_variable('systemduserunitdir')" "systemd_user_unit_dir = '$out/share/systemd/user'"
    '';

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
