{ pkgs, ... }:

let
  start-niri = pkgs.writeTextFile {
    name = "start-niri";
    destination = "/bin/start-niri";
    executable = true;

    text = ''
      #!/usr/bin/env bash

      ## General exports
      export XDG_CURRENT_DESKTOP=niri
      export XDG_SESSION_DESKTOP=niri
      export XDG_SESSION_TYPE=wayland

      ## Load user environment customizations
      if [ -f "''${XDG_CONFIG_HOME:-$HOME/.config}/niri/environment" ]; then
          set -o allexport
          # shellcheck source=/dev/null
          . "''${XDG_CONFIG_HOME:-$HOME/.config}/niri/environment"
          set +o allexport
      fi

      # Start Niri and send output to the journal
      exec systemd-cat -- niri
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
    wlopm
    wofi
    xwayland-satellite
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = "gtk";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  programs.niri.enable = true;
}
