{ config, pkgs, ... }:

let
  start-hypr = pkgs.writeTextFile {
    name = "start-hypr";
    destination = "/bin/start-hypr";
    executable = true;

    text = ''
      #!/bin/sh

      ## General exports
      export XDG_CURRENT_DESKTOP=hyprland
      export XDG_SESSION_DESKTOP=hyprland
      export XDG_SESSION_TYPE=wayland

      ## Hardware compatibility
      case $(systemd-detect-virt --vm) in
          "none"|"")
              ;;
          "kvm")
              export WLR_NO_HARDWARE_CURSORS=1
              ;;
          *)
              export WLR_NO_HARDWARE_CURSORS=1
              ;;
      esac
      
      ## Load user environment customizations
      if [ -f "''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/environment" ]; then
          set -o allexport
          # shellcheck source=/dev/null
          . "''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/environment"
          set +o allexport
      fi
      
      # Start hyprland and send output to the journal
      exec systemd-cat -- Hyprland
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
      slurp
      start-hypr
      swaybg
      wireplumber
      wl-clipboard
      wofi
    ];

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    programs.hyprland = {
      enable = true;
      package = pkgs.unstable.hyprland;
    };
  };
}
