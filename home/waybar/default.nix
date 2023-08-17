{ config, pkgs, ... }:

let
  now-playing = pkgs.stdenv.mkDerivation {
    name = "now-playing";

    propagatedBuildInputs = with pkgs; [
      (python3.withPackages (ps: with ps; [
        pygobject3
      ]))
      pkgs.playerctl
    ];

    nativeBuildInputs = [ pkgs.wrapGAppsHook ];
    buildInputs = [ pkgs.gobject-introspection ];

    dontUnpack = true;
    installPhase = "install -Dm755 ${./now-playing.py} $out/bin/now-playing";
  };

  weather = pkgs.stdenv.mkDerivation {
    name = "weather";

    propagatedBuildInputs = with pkgs; [
      (python3.withPackages (ps: with ps; [
        pyquery
      ]))
    ];

    dontUnpack = true;
    installPhase = "install -Dm755 ${./weather.py} $out/bin/weather";
  };
in {
  programs.waybar.enable = true;
  programs.waybar.style = ./style.css;

  programs.waybar.settings.default = {
    layer = "top";
    position = "top";
    height = 30;

    modules-left = ["idle_inhibitor" "cpu" "memory" "disk" "sway/mode" "sway/window"];
    modules-center = ["sway/workspaces"];
    modules-right = ["custom/media" "custom/weather" "pulseaudio#sink" "backlight" "battery" "clock" "tray"];
    
    "backlight" = {
      "format" = "{percent}% {icon}";
      "format-icons" = [
        ""
      ];
    };

    "battery" = {
      "states" = {
        "warning" = 30;
        "critical" = 15;
      };
      "format" = "{capacity}% {icon}";
      "format-charging" = "{capacity}% ";
      "format-plugged" = "{capacity}% ";
      "format-alt" = "{time} {icon}";
      "format-icons" = [
        ""
        ""
        ""
        ""
        ""
      ];
    };

    "battery#bat2" = {
      "bat" = "BAT2";
    };

    "clock" = {
      "format" = "{:%a %b %e %I:%M %p}";
      "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      "format-alt" = "{:%Y-%m-%d}";
    };

    "cpu" = {
      "format" = "{usage}% ";
      "tooltip" = false;
    };

    "custom/media" = {
      "format" = "{icon} {}";
      "return-type" = "json";
      "max-length" = 40;
      "escape" = true;
      "exec" = "${now-playing}/bin/now-playing";
    };

    "custom/weather" = {
      "restart-interval" = 600;
      "return-type" = "json";
      "exec" = "${weather}/bin/weather";
    };

    "disk" = {
      "interval" = 30;
      "format" = "{percentage_used}% <span></span> ";
    };

    "idle_inhibitor" = {
      "format" = "{icon}";
      "format-icons" = {
        "activated" = "";
        "deactivated" = "";
      };
      "on-update" = "/tmp/k.sh";
    };

    "memory" = {
      "format" = "{}% ";
    };

    "network" = {
      "format-wifi" = "{signalStrength}% ";
      "format-ethernet" = "";
      "format-linked" = "{ifname} (No IP) ";
      "format-disconnected" = "Disconnected ⚠";
      "format-alt" = "{essid}: {ipaddr}/{cidr}";
    };

    "pulseaudio#sink" = {
      "format" = "{volume}% {icon}";
      "format-bluetooth" = "{volume}% {icon}";
      "format-bluetooth-muted" = " {icon}";
      "format-muted" = "0%  ";
      "format-source" = "";
      "format-source-muted" = "";
      "format-icons" = {
        "headphone" = "";
        "hands-free" = "";
        "headset" = "";
        "phone" = "";
        "portable" = "";
        "car" = "";
        "default" = [
          ""
          ""
          ""
        ];
      };
      "on-click" = "${pkgs.pavucontrol}/bin/pavucontrol";
    };

    "pulseaudio#source" = {
      "format" = "{format_source}";
      "format-bluetooth" = "{format_source}";
      "format-bluetooth-muted" = "{format_source}";
      "format-muted" = "{format_source}";
      "format-source" = "{volume}% ";
      "format-source-muted" = "0% ";
      "format-icons" = {
        "headphone" = "";
        "hands-free" = "";
        "headset" = "";
        "phone" = "";
        "portable" = "";
        "car" = "";
        "default" = [
          ""
          ""
          ""
        ];
      };
      "on-click" = "${pkgs.pavucontrol}/bin/pavucontrol";
    };

    "sway/mode" = {
      "format" = "{}";
    };

    "sway/window" = {
      "format" = "{}";
      "max-length" = 50;
      "all-outputs" = true;
      "offscreen-css" = true;
      "offscreen-css-text" = "(inactive)";
      "rewrite" = {
        "(.*) — Mozilla Firefox" = "  $1";
      };
    };

    "sway/workspaces" = {
      "disable-scroll" = true;
      "all-outputs" = false;
      "format" = "{name}";
      "format-icons" = {
        "urgent" = "";
        "focused" = "";
        "default" = "";
      };
    };

    "temperature" = {
      "critical-threshold" = 80;
      "format" = "{temperatureC}ଌ {icon}";
      "format-icons" = [
        ""
        ""
        ""
      ];
    };

    "tray" = {
      "spacing" = 10;
    };
  };
}
