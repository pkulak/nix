{ pkgs, ... }:

let
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

  switch-audio = pkgs.writeShellApplication {
    name = "switch-audio";
    runtimeInputs = with pkgs; [ libnotify ];
    text = builtins.readFile ./switch-audio.sh;
    checkPhase = "";
  };
in {
  home.packages = [
    wofi-power wofi-emoji switch-audio
  ];

  xdg.configFile."niri/environment" = {
    executable = true;

    text = # bash
      ''
        #!/usr/bin/env bash

        export TERMINAL="footclient"
        export TERM="foot"
        export BROWSER="firefox"
        export EDITOR="nvim"
        export VISUAL="nvim"

        export _JAVA_AWT_WM_NONREPARENTING=1
        export GTK_THEME="Adwaita-dark"

        export JAVA_HOME=${pkgs.jdk17}/lib/openjdk
        export JAVA_11_HOME=${pkgs.jdk11}/lib/openjdk
        export JAVA_17_HOME=${pkgs.jdk17}/lib/openjdk

        export MOZ_ENABLE_WAYLAND=1

        # jam some Vevo stuff in the env to make builds easier
        if test -f /home/phil/.m2/settings.xml; then
          export NEXUS_USER=deployment
          export NEXUS_PASSWORD=$(${pkgs.xq-xml}/bin/xq /home/phil/.m2/settings.xml -x "/settings/servers/*[1]/password")
        fi

        # and load secrets
        if test -f /home/phil/.config/niri/secrets; then
          source /home/phil/.config/niri/secrets
        fi
      '';
  };

  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;
    
    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;

    # Override just for GTK4 to use plain Adwaita
    gtk4.extraConfig = {
      gtk-theme-name = "Adwaita";
    };
  };

  qt = {
    enable = true;
    style = {
      name = "adwaita-dark";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # use systemd to manage some services
  systemd.user.services.wlsunset = {
    Unit = {
      Description = "wlsunet daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service.ExecStart = "${pkgs.wlsunset}/bin/wlsunset -l 45.5 -L -122.6 -g 0.8";
    Install.WantedBy = [ "niri.service" ];
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "mako daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service.ExecStart = "${pkgs.mako}/bin/mako";
    Install.WantedBy = [ "niri.service" ];
  };

  systemd.user.services.polkit = {
    Unit = {
      Description = "polkit authentication agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service.ExecStart =
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    Install.WantedBy = [ "niri.service" ];
  };

  systemd.user.services.waybar = {
    Unit = {
      Description = "waybar daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" "network-online.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service.ExecStart = "${pkgs.waybar}/bin/waybar";
    Install.WantedBy = [ "niri.service" ];
  };

  systemd.user.services.swaybg = {
    Unit = {
      Description = "swaybg daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service.ExecStart =
      "${pkgs.swaybg}/bin/swaybg -i ${./wallpaper.png} -m fill";
    Install.WantedBy = [ "niri.service" ];
  };

  systemd.user.services.foot = {
    Unit = {
      Description = "foot terminal server";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service.ExecStart = "${pkgs.foot}/bin/foot --server";
    Install.WantedBy = [ "niri.service" ];
  };
}
