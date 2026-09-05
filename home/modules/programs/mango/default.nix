_: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.mango;
in {
  options.programs.mango = {
    enable = lib.mkEnableOption "mango";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.bibata-cursors];

    xdg.configFile."mango/config.conf".text = ''
      # More option see https://github.com/DreamMaoMao/mango/wiki/

      exec-once=${lib.getExe config.programs.noctalia.package}

      # Window effect
      blur=0
      blur_layer=0
      blur_optimized=1
      blur_params_num_passes = 2
      blur_params_radius = 5
      blur_params_noise = 0.02
      blur_params_brightness = 0.9
      blur_params_contrast = 0.9
      blur_params_saturation = 1.2

      shadows = 0
      layer_shadows = 0
      shadow_only_floating = 1
      shadows_size = 10
      shadows_blur = 15
      shadows_position_x = 0
      shadows_position_y = 0
      shadowscolor= 0x000000ff

      border_radius=6
      no_radius_when_single=0
      focused_opacity=1.0
      unfocused_opacity=1.0

      # Animation Configuration(support type:zoom,slide)
      # tag_animation_direction: 1-horizontal,0-vertical
      animations=1
      layer_animations=1
      animation_type_open=slide
      animation_type_close=slide
      animation_fade_in=1
      animation_fade_out=1
      tag_animation_direction=1
      zoom_initial_ratio=0.4
      zoom_end_ratio=0.8
      fadein_begin_opacity=0.5
      fadeout_begin_opacity=0.8
      animation_duration_move=500
      animation_duration_open=400
      animation_duration_tag=350
      animation_duration_close=800
      animation_duration_focus=0
      animation_curve_open=0.46,1.0,0.29,1
      animation_curve_move=0.46,1.0,0.29,1
      animation_curve_tag=0.46,1.0,0.29,1
      animation_curve_close=0.08,0.92,0,1
      animation_curve_focus=0.46,1.0,0.29,1
      animation_curve_opafadeout=0.5,0.5,0.5,0.5
      animation_curve_opafadein=0.46,1.0,0.29,1

      # Scroller Layout Setting
      scroller_structs=20
      scroller_default_proportion=0.8
      scroller_focus_center=0
      scroller_prefer_center=0
      edge_scroller_pointer_focus=1
      edge_scroller_focus_allow_speed=0.0
      scroller_default_proportion_single=1.0
      scroller_proportion_preset=0.5,0.8,1.0

      # Master-Stack Layout Setting
      new_is_master=1
      default_mfact=0.55
      default_nmaster=1
      smartgaps=0

      # Dwindle Layout Setting
      dwindle_smart_split=0
      dwindle_drop_simple_split=1
      dwindle_manual_split=0
      dwindle_hsplit=1
      dwindle_vsplit=1
      dwindle_preserve_split=0

      # Overview Setting
      hotarea_size=10
      enable_hotarea=0
      ov_tab_mode=0
      ov_no_resize=1
      overviewgappi=5
      overviewgappo=30

      # Misc
      no_border_when_single=0
      axis_bind_apply_timeout=100
      focus_on_activate=1
      idleinhibit_ignore_visible=0
      sloppyfocus=1
      warpcursor=1
      focus_cross_monitor=1
      focus_cross_tag=0
      enable_floating_snap=0
      snap_distance=30
      cursor_size=24
      cursor_theme=Bibata-Modern-Classic
      drag_tile_to_tile=1
      drag_tile_small=1

      # keyboard
      repeat_rate=25
      repeat_delay=600
      numlockon=0
      xkb_rules_layout=de

      # Trackpad
      # need relogin to make it apply
      disable_trackpad=0
      tap_to_click=1
      tap_and_drag=1
      drag_lock=1
      trackpad_natural_scrolling=0
      disable_while_typing=1
      left_handed=0
      middle_button_emulation=0
      swipe_min_threshold=1

      # mouse
      # need relogin to make it apply
      mouse_natural_scrolling=0

      # Appearance
      gappih=2
      gappiv=2
      gappoh=4
      gappov=4
      scratchpad_width_ratio=0.8
      scratchpad_height_ratio=0.9
      borderpx=4
      rootcolor=0x201b14ff
      bordercolor=0x444444ff
      dropcolor=0x8FBA7C55
      splitcolor=0xEB441EFF
      focuscolor=0xc9b890ff
      maximizescreencolor=0x89aa61ff
      urgentcolor=0xad401fff
      scratchpadcolor=0x516c93ff
      globalcolor=0xb153a7ff
      overlaycolor=0x14a57cff

      # layout support:
      # tile,scroller,grid,deck,monocle,center_tile,vertical_tile,vertical_scroller
      tagrule=id:1,layout_name:tile
      tagrule=id:2,layout_name:tile
      tagrule=id:3,layout_name:tile
      tagrule=id:4,layout_name:tile
      tagrule=id:5,layout_name:tile
      tagrule=id:6,layout_name:tile
      tagrule=id:7,layout_name:tile
      tagrule=id:8,layout_name:tile
      tagrule=id:9,layout_name:tile

      # Key Bindings
      # key name refer to `xev` or `wev` command output,
      # mod keys name: super,ctrl,alt,shift,none

      # reload config
      bind=SUPER,r,reload_config

      # menu and terminal
      bind=Alt,Return,spawn,ghostty

      # exit
      bind=SUPER,m,quit
      bind=ALT,q,killclient,

      # switch window focus
      bind=SUPER,Tab,focusstack,next
      bind=ALT,Left,focusdir,left
      bind=ALT,Right,focusdir,right
      bind=ALT,Up,focusdir,up
      bind=ALT,Down,focusdir,down

      # swap window
      bind=SUPER+SHIFT,Up,exchange_client,up
      bind=SUPER+SHIFT,Down,exchange_client,down
      bind=SUPER+SHIFT,Left,exchange_client,left
      bind=SUPER+SHIFT,Right,exchange_client,right

      # switch window status
      bind=SUPER,g,toggleglobal,
      bind=ALT,Tab,togglejump,
      bind=ALT,backslash,togglefloating,
      bind=ALT,a,togglemaximizescreen,
      bind=ALT,f,togglefullscreen,
      bind=ALT+SHIFT,f,togglefakefullscreen,
      bind=SUPER,i,minimized,
      bind=SUPER,o,toggleoverlay,
      bind=SUPER+SHIFT,I,restore_minimized
      bind=ALT,z,toggle_scratchpad

      # scroller layout
      bind=ALT,e,set_proportion,1.0
      bind=ALT,x,switch_proportion_preset,
      bind=alt+super+ctrl,Left,scroller_stack,left
      bind=alt+super+ctrl,Right,scroller_stack,right
      bind=alt+super+ctrl,Up,scroller_stack,up
      bind=alt+super+ctrl,Down,scroller_stack,down

      #dwindle layout(manual split mode)
      bind=alt+shift,Return,dwindle_toggle_split_direction

      # switch layout
      bind=SUPER,n,switch_layout

      # tag switch
      bind=SUPER,Left,viewtoleft,0
      bind=ALT,Left,viewtoleft_have_client,0
      bind=SUPER,Right,viewtoright,0
      bind=ALT,Right,viewtoright_have_client,0
      bind=ALT+SUPER,Left,tagtoleft,0
      bind=ALT+SUPER,Right,tagtoright,0

      bind=Super,1,view,1,0
      bind=Super,2,view,2,0
      bind=Super,3,view,3,0
      bind=Super,4,view,4,0
      bind=Super,5,view,5,0
      bind=Super,6,view,6,0
      bind=Super,7,view,7,0
      bind=Super,8,view,8,0
      bind=Super,9,view,9,0

      bind=Super+Ctrl,1,toggleview,1,0
      bind=Super+Ctrl,2,toggleview,2,0
      bind=Super+Ctrl,3,toggleview,3,0
      bind=Super+Ctrl,4,toggleview,4,0
      bind=Super+Ctrl,5,toggleview,5,0
      bind=Super+Ctrl,6,toggleview,6,0
      bind=Super+Ctrl,7,toggleview,7,0
      bind=Super+Ctrl,8,toggleview,8,0
      bind=Super+Ctrl,9,toggleview,9,0

      # tag: move client to the tag and focus it
      # tagsilent: move client to the tag and not focus it
      # bind=Alt,1,tagsilent,1
      bind=Super+Shift,1,tag,1,0
      bind=Super+Shift,2,tag,2,0
      bind=Super+Shift,3,tag,3,0
      bind=Super+Shift,4,tag,4,0
      bind=Super+Shift,5,tag,5,0
      bind=Super+Shift,6,tag,6,0
      bind=Super+Shift,7,tag,7,0
      bind=Super+Shift,8,tag,8,0
      bind=Super+Shift,9,tag,9,0

      bind=Super+Ctrl+Shift,1,toggletag,1,0
      bind=Super+Ctrl+Shift,2,toggletag,2,0
      bind=Super+Ctrl+Shift,3,toggletag,3,0
      bind=Super+Ctrl+Shift,4,toggletag,4,0
      bind=Super+Ctrl+Shift,5,toggletag,5,0
      bind=Super+Ctrl+Shift,6,toggletag,6,0
      bind=Super+Ctrl+Shift,7,toggletag,7,0
      bind=Super+Ctrl+Shift,8,toggletag,8,0
      bind=Super+Ctrl+Shift,9,toggletag,9,0

      # monitor switch
      bind=alt+shift,Left,focusmon,left
      bind=alt+shift,Right,focusmon,right
      bind=SUPER+Alt,Left,tagmon,left
      bind=SUPER+Alt,Right,tagmon,right

      # gaps
      bind=ALT+SHIFT,X,incgaps,1
      bind=ALT+SHIFT,Z,incgaps,-1
      bind=ALT+SHIFT,R,togglegaps

      # movewin
      # bind=CTRL+SHIFT,Up,movewin,+0,-50
      # bind=CTRL+SHIFT,Down,movewin,+0,+50
      # bind=CTRL+SHIFT,Left,movewin,-50,+0
      # bind=CTRL+SHIFT,Right,movewin,+50,+0

      # resizewin
      # bind=CTRL+ALT,Up,resizewin,+0,-50
      # bind=CTRL+ALT,Down,resizewin,+0,+50
      # bind=CTRL+ALT,Left,resizewin,-50,+0
      # bind=CTRL+ALT,Right,resizewin,+50,+0

      # Mouse Button Bindings
      # btn_left and btn_right can't bind none mod key
      mousebind=SUPER,btn_left,moveresize,curmove
      mousebind=SUPER,btn_middle,togglemaximizescreen,0
      mousebind=SUPER,btn_right,moveresize,curresize


      # Axis Bindings
      axisbind=SUPER,UP,viewtoleft_have_client
      axisbind=SUPER,DOWN,viewtoright_have_client

      ## noctalia bindings and addons
      # Core binds
      bind=SUPER,space,spawn,noctalia msg panel-toggle launcher
      bind=SUPER,s,spawn,noctalia msg panel-toggle control-center
      bind=SUPER,comma,spawn,noctalia msg settings-toggle
      bind=SUPER,l,spawn,noctalia msg session lock

      # Media keys
      bind=NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up
      bind=NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down
      bind=NONE,XF86AudioMute,spawn,noctalia msg volume-mute
      bind=NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up
      bind=NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down
      bindr=SUPER,b,spawn,${pkgs.writers.writeBash "take-screenshot" {
          makeWrapperArgs = [
            "--prefix"
            "PATH"
            ":"
            (lib.makeBinPath [pkgs.grim pkgs.slurp pkgs.satty pkgs.wl-clipboard])
          ];
        }
        # bash
        ''
          mkdir -p ~/Pictures/Screenshots
          grim -t ppm -g "$(slurp)" - | \
            satty --filename - \
              --fullscreen \
              --copy-command wl-copy \
              --output-filename ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png
        ''}

      # layer rule
      layerrule=animation_type_open:zoom,layer_name:rofi
      layerrule=animation_type_close:zoom,layer_name:rofi

      source=~/.config/mango/noctalia.conf
    '';
  };
}
