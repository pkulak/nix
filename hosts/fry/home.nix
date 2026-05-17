{ pkgs, ... }:

let
  lock = "${pkgs.swaylock-effects}/bin/swaylock -f";
  pause = "${pkgs.playerctl}/bin/playerctl pause";
  powerOffMonitors = "${pkgs.niri}/bin/niri msg action power-off-monitors";
  suspend = "${pkgs.systemd}/bin/systemctl suspend";
in
{
  home.stateVersion = "23.05";
  programs.fish.shellAliases = {
    ts = "sudo tailscale switch kulak.us && sudo tailscale up";
  };

  xdg.configFile."niri/host.kdl".text = # kdl
    ''
      window-rule {
          match app-id="footclient"
          default-column-width { proportion 0.3; }
      }

      window-rule {
          match app-id="jetbrains-idea"
          default-column-width { proportion 0.6; }
      }

      window-rule {
          match app-id="matui"
          default-column-width { proportion 0.4; }
      }

      window-rule {
          match app-id="termfilechooser"
          default-column-width { proportion 0.5; }
      }

      window-rule {
          match app-id=r#"firefox$"#
          default-column-width { proportion 0.5; }
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
            timeout 300 '${pause}' \
            timeout 540 '${lock}' \
            timeout 600 '${powerOffMonitors}' \
            timeout 7200 '${suspend}' \
            before-sleep '${lock}' \
            lock '${lock}'
      '';

    Service.Environment = "PATH=/bin:/run/current-system/sw/bin";
    Install.WantedBy = [ "niri.service" ];
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
