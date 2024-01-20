{ config, pkgs, ... }:

let
  rules = pkgs.writeShellApplication {
    name = "rules";
    runtimeInputs = with pkgs; [ socat ];
    text = ./rules.sh;
  };

  imap-notify-packages = ps: with ps; [
    (
      buildPythonPackage rec {
        pname = "jmapc";
        version = "0.2.18";
        format = "pyproject";
        doCheck = false;

        src = fetchPypi {
          inherit pname version;
          sha256 = "sha256-phzN78c4ZuLskwW2UkYD0g6grRcl3o0mhi4RABG+rTs=";
        };

        propagatedBuildInputs = [
          pkgs.python3Packages.dataclasses-json
          pkgs.python3Packages.poetry-core
          pkgs.python3Packages.poetry-dynamic-versioning
          pkgs.python3Packages.python-dateutil
          pkgs.python3Packages.requests
          pkgs.python3Packages.sseclient
        ];
      }
    )
  ];

  imap-notify = pkgs.stdenv.mkDerivation {
    name = "imap-notify";

    propagatedBuildInputs = with pkgs; [
      (python3.withPackages imap-notify-packages)
    ];

    dontUnpack = true;

    installPhase = ''
      install -Dm755 ${./imap-notify.py} $out/bin/imap-notify
      install -Dm755 ${./mailbox.png} $out/share/icon.png
      substituteInPlace $out/bin/imap-notify --replace 'icon.png' "$out/share/icon.png"
    '';
  };
in {
  imports = [
    ./keybinds.nix
  ];

  xdg.configFile."hypr/environment" = {
    executable = true;

    text = ''
      #!/usr/bin/env bash

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

      export JAVA_HOME=${pkgs.jdk17}/lib/openjdk
      export JAVA_11_HOME=${pkgs.jdk11}/lib/openjdk
      export JAVA_17_HOME=${pkgs.jdk17}/lib/openjdk

      export MOZ_ENABLE_WAYLAND=1
      export MOZ_WEBRENDER=1
      export MOZ_ACCELERATED=1

      # jam some Vevo stuff in the env to make builds easier
      if test -f /home/phil/.m2/settings.xml; then
        export NEXUS_USER=deployment
        export NEXUS_PASSWORD=$(${pkgs.xq-xml}/bin/xq /home/phil/.m2/settings.xml -x "/settings/servers/*[1]/password")
      fi
    '';
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita-dark";
    };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;

    settings = {
      "$mod" = "SUPER";
      monitor = ",preferred,auto,auto";

      exec-once = [
        "${rules}/bin/rules"
        "waybar"
        "swaybg -i ${./wallpaper.png} -m fill"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        natural_scroll = true;
        scroll_method = "on_button_down";
        scroll_button = "275";
        accel_profile = "adaptive";
        
        repeat_delay = 200;
        repeat_rate = 30;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        cursor_inactive_timeout = 4;
        "col.active_border" = "rgba(ffffffaa)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "master";
        allow_tearing = false;
      };

      decoration = {
        rounding = 10;

        blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
        };

        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      group = {
        groupbar = {
          gradients = false;
          render_titles = false;
        };
      };

      animations = {
        enabled = true;

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.0A";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
          pseudotile = true;
          preserve_split = true;
      };

      master = {
        new_is_master = false;
      };

      windowrulev2 = [
        # Sublime Merge
        "float,class:sublime_merge"
        "dimaround,class:sublime_merge"
        "size 1440 1024,class:sublime_merge"
        "center 1,class:sublime_merge"

        # Popup Terminals (and anything else)
        "float,class:floating"
        "size 1280 720,class:floating"
        "center 1,class:floating"

        # Volume Control
        "float,class:pavucontrol"

        # Music
        "workspace special:scratch,class:.sublime-music-wrapped"
      ];

      workspace = [
        "special:scratch,gapsin:30,gapsout:128"
      ];

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        mouse_move_enables_dpms = false;
        key_press_enables_dpms = true;
      };
    };
  };

  # use systemd to manage some services
  systemd.user.services.wlsunset = {
    Unit.Description = "wlsunset daemon";
    Service.ExecStart = "${pkgs.wlsunset}/bin/wlsunset -l 45.5 -L -122.6 -g 0.8"; 
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  systemd.user.services.imap-notify = {
    Unit.Description = "email notifications daemon";
    Service.ExecStart = "${imap-notify}/bin/imap-notify"; 
    Service.Environment = "PATH=${pkgs.libnotify}/bin";
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  systemd.user.services.mako = {
    Unit.Description = "mako daemon";
    Service.ExecStart = "${pkgs.mako}/bin/mako"; 
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  systemd.user.services.polkit = {
    Unit.Description = "polkit daemon";
    Service.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; 
    Install.WantedBy = [ "hyprland-session.target" ];
  };
}
