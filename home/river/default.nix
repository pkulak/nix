{ pkgs, ... }:

let
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
          pkgs.python3Packages.keyring
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

  # get rid of this when nikpkgs updates
  wlsunset = pkgs.stdenv.mkDerivation rec {
    pname = "wlsunset";
    version = "0.4.0";

    src = pkgs.fetchFromSourcehut {
      owner = "~kennylevinsen";
      repo = pname;
      rev = version;
      sha256 = "sha256-U/yROKkU9pOBLIIIsmkltF64tt5ZR97EAxxGgrFYwNg=";
    };

    strictDeps = true;
    depsBuildBuild = with pkgs; [ pkg-config ];
    nativeBuildInputs = with pkgs; [ meson pkg-config ninja wayland-scanner scdoc ];
    buildInputs = with pkgs; [ wayland wayland-protocols ];
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

  init = pkgs.stdenv.mkDerivation {
    name = "init";
    dontUnpack = true;

    installPhase = ''
      install -Dm755 ${./init} $out/bin/init
      substituteInPlace $out/bin/init --replace 'wofi-emoji' '${wofi-emoji}/bin/wofi-emoji'
      substituteInPlace $out/bin/init --replace 'wofi-power' '${wofi-power}/bin/wofi-power'
      substituteInPlace $out/bin/init --replace 'wallpaper.png' '${./wallpaper.png}'
    '';
  };
in {
  home.packages = [
    (pkgs.callPackage ./bedload.nix pkgs)
    (pkgs.callPackage ./get-tag-name.nix pkgs)
  ];

  xdg.configFile."river/environment" = {
    executable = true;

    text = ''
      #!/usr/bin/env bash

      export TERMINAL="alacritty"
      export BROWSER="firefox"
      export EDITOR="nvim"
      export VISUAL="nvim"

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

  xdg.configFile."river/init" = {
    executable = true;
    source = "${init}/bin/init";
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

  # use systemd to manage some services
  systemd.user.targets.river-session = {
    Unit = {
      Description = "River compositor session";
      Documentation = "man:systemd.special";
      BindsTo = "graphical-session.target";
      Wants = "graphical-session-pre.target";
      After = "graphical-session-pre.target";
    };
  };

  systemd.user.services.wlsunset = {
    Unit.Description = "wlsunset daemon";
    Service.ExecStart = "${wlsunset}/bin/wlsunset -l 45.5 -L -122.6 -g 0.8"; 
    Install.WantedBy = [ "river-session.target" ];
  };

  systemd.user.services.wlsunset-restart = {
    Unit = {
      Description = "restart wlsunset on resume";
      After = "suspend.target";
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user --no-block restart wlsunset.service";
    };

    Install.WantedBy = [ "suspend.target" ];
  };

  systemd.user.services.imap-notify = {
    Unit.Description = "email notifications daemon";
    Service.ExecStart = "${imap-notify}/bin/imap-notify"; 
    Service.Environment = "PATH=${pkgs.libnotify}/bin";
    Install.WantedBy = [ "river-session.target" "network-online.target" ];
  };

  systemd.user.services.mako = {
    Unit.Description = "mako daemon";
    Service.ExecStart = "${pkgs.mako}/bin/mako"; 
    Install.WantedBy = [ "river-session.target" ];
  };

  systemd.user.services.polkit = {
    Unit.Description = "polkit daemon";
    Service.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; 
    Install.WantedBy = [ "river-session.target" ];
  };

  systemd.user.services.waybar = {
    Unit.Description = "waybar daemon";
    Service.ExecStart = "${pkgs.waybar}/bin/waybar"; 
    Install.WantedBy = [ "river-session.target" ];
  };

  systemd.user.services.swaybg = {
    Unit.Description = "swaybg daemon";
    Service.ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${./wallpaper.png} -m fill"; 
    Install.WantedBy = [ "river-session.target" ];
  };
}
