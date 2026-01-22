{ pkgs, lib, ... }:

{
  programs.fish.shellAliases = {
    ts = "sudo tailscale switch kulak.us && sudo tailscale up --accept-routes";
  };

  xdg.configFile."niri/host.kdl".text = # kdl
    ''
      input {
          keyboard {
              xkb {
                  options "altwin:swap_lalt_lwin,caps:escape"
              }
          }
      } 

      output "eDP-1" {
          layout {
              preset-column-widths {
                  proportion 0.6
                  proportion 0.8
              }
              
              default-column-width { proportion 0.6; }
          }
      }

      window-rule {
          match app-id="jetbrains-idea"
          default-column-width { proportion 1.0; }
      }

      window-rule {
          match app-id="com.mitchellh.ghostty"
          default-column-width { proportion 0.4; }
      }
    '';

  systemd.user.services.swayidle = {
    Unit = {
      Description = "swayidle daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };

    Service.ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 120 'niri msg action power-off-monitors' \
            timeout 600 'systemctl suspend'
      '';

    Service.Environment = "PATH=/bin:/run/current-system/sw/bin";
    Install.WantedBy = [ "niri.service" ];
  };

  programs.firefox.profiles.phil.extraConfig = ''
    user_pref("mousewheel.default.delta_multiplier_y", 50);
  '';

  home.packages = [ pkgs.networkmanagerapplet ];

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "network manager applet";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service.ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    Install.WantedBy = [ "niri.service" ];
  };
}
