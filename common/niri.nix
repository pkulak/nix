{ pkgs, ... }:

let
  start-niri = pkgs.writeTextFile {
    name = "start-niri";
    destination = "/bin/start-niri";
    executable = true;

    text = ''
      #!/usr/bin/env bash

      # Load user environment
      if [ -f "''${XDG_CONFIG_HOME:-$HOME/.config}/niri/environment" ]; then
          set -o allexport
          . "''${XDG_CONFIG_HOME:-$HOME/.config}/niri/environment"
          set +o allexport
      fi

      # Start Niri in Systemd
      exec niri-session
    '';
  };

in {
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    gnome-themes-extra
    grim
    mako
    playerctl
    slurp
    start-niri
    swaybg
    wireplumber
    wl-clipboard
    wlr-randr
    rofi
    xwayland-satellite
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  programs.niri.enable = true;
}
