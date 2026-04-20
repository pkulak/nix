{ self, inputs, ... }:
{
  flake.homeModules.core =
    {
      config,
      pkgs,
      host,
      ...
    }:
    let
      rebuild = pkgs.writeShellApplication {
        name = "rebuild";
        text = "sudo nixos-rebuild --flake ~/nix/#${host} switch";
      };

      update = pkgs.writeShellApplication {
        name = "update";
        text = ''
          cd ~/nix
          nix flake update --flake ~/nix
          cd "$OLDPWD"
        '';
      };

      sync-notes = pkgs.writeShellApplication {
        name = "sync-notes";
        runtimeInputs = with pkgs; [
          coreutils
          git
          openssh
        ];
        text = ''
          cd ~/notes

          if [[ $(git status --porcelain) ]]; then
            git add .
            git -c "user.name=Phil Kulak" -c "user.email=phil@kulak.us" commit -m "$(date)"
            git pull --rebase
            git push origin main
          else
            git pull --rebase
          fi
        '';
      };

      public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C phil@kulak.us";
    in
    {
      home = {
        username = "phil";
        homeDirectory = "/home/phil";
        packages = [
          rebuild
          update
          sync-notes
        ];
      };

      # sync our notes on a schedule
      systemd.user.services.sync-notes = {
        Unit.Description = "Synchronize my notes repo";
        Service.ExecStart = "${sync-notes}/bin/sync-notes";
      };

      systemd.user.timers.sync-notes = {
        Unit.Description = "Synchronize notes hourly";
        Timer.OnCalendar = "hourly";
        Install.WantedBy = [ "timers.target" ];
      };

      home.file = {
        # SSH
        ".ssh/allowed_signers".text = "* ${public-key}";
        ".ssh/id_ed25519.pub".text = public-key;
      };
    };
}
