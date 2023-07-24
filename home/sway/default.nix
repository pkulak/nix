{ config, pkgs, ... }:

let
  autotiling = pkgs.stdenv.mkDerivation {
    name = "autotiling";

    propagatedBuildInputs = with pkgs; [
      (python3.withPackages (ps: with ps; [
        i3ipc
      ]))
    ];

    dontUnpack = true;
    installPhase = "install -Dm755 ${./autotiling.py} $out/bin/autotiling";
  };

  wofi-power = pkgs.stdenv.mkDerivation {
    name = "wofi-power";
    nativeBuildInputs = with pkgs; [ makeWrapper ];
    dontUnpack = true;

    installPhase = ''
      makeWrapper ${./wofi-power} $out/bin/wofi-power \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.wofi ]}
    '';
  };

  wofi-emoji = pkgs.stdenv.mkDerivation {
    name = "wofi-emoji";
    nativeBuildInputs = with pkgs; [ makeWrapper ];
    dontUnpack = true;

    installPhase = ''
      makeWrapper ${./wofi-emoji} $out/bin/wofi-emoji \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.wofi ]}
    '';
  };

  alacritty = "${pkgs.alacritty}/bin/alacritty";
  fish = "${pkgs.fish}/bin/fish";
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
in {
  xdg.configFile."sway/environment" = {
    executable = true;

    text = ''
      #!/bin/sh

      export TERMINAL="alacritty"
      export BROWSER="firefox"
      export EDITOR="nvim"
      export VISUAL="nvim"

      export GIT_AUTHOR_NAME="Phil Kulak"
      export GIT_AUTHOR_EMAIL="phil@kulak.us"

      export SDL_VIDEODRIVER="wayland"
      export QT_QPA_PLATFORM="wayland"
      export GDK_BACKEND="wayland,x11"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export JAVA_HOME=${pkgs.jdk11}/lib/openjdk

      export MOZ_ENABLE_WAYLAND=1
      export MOZ_WEBRENDER=1
      export MOZ_ACCELERATED=1
    '';
  };

  wayland.windowManager.sway.enable = true;

  wayland.windowManager.sway.config = rec {
    menu = "${pkgs.wofi}/bin/wofi -a -b -I -modi drun --show drun";
    terminal = "${alacritty} -e ${fish}";
    modifier = "Mod4";

    startup = [
      { command = "${autotiling}/bin/autotiling"; }
      { command = "${pkgs.wlsunset}/bin/wlsunset -l 45.5 -L -122.6 -g 0.8"; }
      { command = "${pkgs.mako}/bin/mako"; }
      { command = "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark"; }
      { command = "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface icon-theme 'Adwaita"; }
      { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
    ];

    input = {
      "1149:8257:Kensington_Slimblade_Trackball" = {
        natural_scroll = "enabled";
        scroll_method = "on_button_down";
        scroll_button = "275";
        accel_profile = "adaptive";
      };

      "type:touchpad" = {
        natural_scroll = "enabled";
      };

      "type:pointer" = {
        natural_scroll = "enabled";
      };

      "type:keyboard" = {
        repeat_delay = "200";
        repeat_rate = "30";
      };
    };

    output = {
      "*" = { bg = "${./wallpaper.png} fill"; };
    };

    seat = {
      "*" = { 
        hide_cursor = "3000";
        xcursor_theme = "Adwaita 24";
      };
    };

    keybindings = pkgs.lib.mkOptionDefault {
      "${modifier}+w" = "kill";
      "${modifier}+t" = "layout tabbed";

      # 10 workspaces, please
      "${modifier}+0" = "workspace number 10";
      "${modifier}+Shift+0" = "move container to workspace number 10";

      # Browser
      "${modifier}+p" = "exec ${pkgs.firefox}/bin/firefox";

      # Passthrough
      "F12" = "mode \"passthrough\"";

      # Mako
      "Control+Space" = "exec ${pkgs.mako}/bin/makoctl dismiss";
      "Control+Shift+Space" = "exec ${pkgs.mako}/bin/makoctl dismiss --all";

      # Screenshots
      "${modifier}+Shift+s" = "exec mkdir -p $HOME/Screenshots && ${slurp} | ${grim} -g - $HOME/Screenshots/$(date +'%Y-%m-%d-%H%M%S.png')";

      # Multimedia
      "--locked XF86AudioRaiseVolume" = "exec ${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
      "--locked XF86AudioLowerVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      "--locked XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
      "--locked XF86AudioPlay" = "exec ${playerctl} play-pause";
      "--locked XF86AudioNext" = "exec ${playerctl} next";
      "--locked XF86AudioPrev" = "exec ${playerctl} previous";

      # Wofi
      "${modifier}+x" = "exec ${wofi-power}/bin/wofi-power";
      "${modifier}+Shift+e" = "exec ${wofi-emoji}/bin/wofi-emoji";

      # Popup Terminal
      "${modifier}+Shift+Return" = "exec ${alacritty} --class popup_shell -e ${fish}";

      # File Manager
      "${modifier}+Shift+T" = "exec ${pkgs.xfce.thunar}/bin/thunar";
    };

    window.commands = [
      # Sublime Merge
      { criteria = { app_id = "sublime_merge"; }; command = "floating enable"; }
      { criteria = { app_id = "sublime_merge"; }; command = "resize set 1440 1024"; }

      # Volume Control
      { criteria = { app_id = "pavucontrol"; }; command = "floating enable"; }

      # Popup Terminal
      { criteria = { app_id = "popup_shell"; }; command = "floating enable"; }
      { criteria = { app_id = "popup_shell"; }; command = "resize set 1280 720"; }

      # Zoom Bullshit
      { criteria = { title = "Firefox — Sharing Indicator"; }; command = "floating enable"; }
      { criteria = { title = "Firefox — Sharing Indicator"; }; command = "move scratchpad"; }

      # Steam
      { criteria = { class = "Steam"; }; command = "floating enable"; }
    ];

    modes = {
      passthrough = {
        "F12" = "mode \"default\"";
      };

      resize = {
        h = "resize shrink width 25px";
        j = "resize grow height 25px";
        k = "resize shrink height 25px";
        l = "resize grow width 25px";

        Left = "resize shrink width 25px";
        Down = "resize grow height 25px";
        Up = "resize shrink height 25px";
        Right = "resize grow width 25px";

        Return = "mode \"default\"";
        Escape = "mode \"default\"";
      };
    };

    fonts = { names = ["Ubuntu"]; style = "Regular"; size = 11.0; };
    bars = [];

    gaps = {
      smartBorders = "off";
      smartGaps = false;
      inner = 10;
    };

    floating.border = 3;
    window.border = 3;
    window.titlebar = false;

    colors = {
      focused = {
        background = "#335265";
        border = "#335265";
        childBorder= "#335265";
        indicator = "#335265";
        text = "#FFFFFF";
      };
      focusedInactive = {
        background = "#5F676A";
        border = "#5F676A";
        childBorder= "#5F676A";
        indicator = "#484E50";
        text = "#FFFFFF";
      };
      unfocused = {
        background = "#222222";
        border = "#222222";
        childBorder= "#222222";
        indicator = "#292D2E";
        text = "#888888";
      };
      urgent = {
        background = "#900000";
        border = "#2F343A";
        childBorder= "#900000";
        indicator = "#900000";
        text = "#FFFFFF";
      };
    };
  };

  wayland.windowManager.sway.extraConfig = ''
    bar {
      swaybar_command ${pkgs.waybar}/bin/waybar
    }
  '';
}
