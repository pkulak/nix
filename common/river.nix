{ config, pkgs, ... }:

let
  start-river = pkgs.writeTextFile {
    name = "start-river";
    destination = "/bin/start-river";
    executable = true;

    text = ''
      #!/usr/bin/env bash

      ## General exports
      export XDG_CURRENT_DESKTOP=river
      export XDG_SESSION_DESKTOP=river
      export XDG_SESSION_TYPE=wayland
      
      ## Load user environment customizations
      if [ -f "''${XDG_CONFIG_HOME:-$HOME/.config}/river/environment" ]; then
          set -o allexport
          # shellcheck source=/dev/null
          . "''${XDG_CONFIG_HOME:-$HOME/.config}/river/environment"
          set +o allexport
      fi
      
      # Start River and send output to the journal
      exec systemd-cat -- river
    '';
  };

in
{
  config = {
    environment.systemPackages = with pkgs; [
      alacritty
      glib
      gnome.adwaita-icon-theme
      gnome.gnome-themes-extra
      grim
      mako
      playerctl
      river
      slurp
      start-river
      swaybg
      wireplumber
      wl-clipboard
      wlr-randr
      wlopm
      wofi
    ];

    xdg.portal = {
      enable = true;
      wlr.enable = true;

      config = {
        common.default = [ "wlr" ];
      };
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
