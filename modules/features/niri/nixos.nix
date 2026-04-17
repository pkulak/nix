{ pkgs, ... }:

let
  start-niri = pkgs.writeTextFile {
    name = "start-niri";
    destination = "/bin/start-niri";
    executable = true;

    text = ''
      #!/usr/bin/env bash

      # Load shared environment, just in case
      if [ -f "''${XDG_CONFIG_HOME:-$HOME/.config}/environment.sh" ]; then
          . "''${XDG_CONFIG_HOME:-$HOME/.config}/environment.sh"
      fi

      # Load desktop-specific environment
      if [ -f "''${XDG_CONFIG_HOME:-$HOME/.config}/niri/environment" ]; then
          . "''${XDG_CONFIG_HOME:-$HOME/.config}/niri/environment"
      fi

      # Start Niri in Systemd
      exec niri-session
    '';
  };

in
{
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    gnome-themes-extra
    grim
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

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];

    config.common."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
  };
}
