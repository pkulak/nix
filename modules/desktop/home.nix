{ self, inputs, ... }: {
  flake.homeModules.desktop = { config, pkgs, ... }:
    let
      todo = pkgs.writeShellApplication {
        name = "todo";
        runtimeInputs = with pkgs; [ moreutils ];
        text = ''
          if [ $# -eq 0 ]; then
            nvim ~/notes/tasks.md
            exit
          fi

          echo -e "$(date +%F): $*" | cat - ~/notes/tasks.md | sponge ~/notes/tasks.md
        '';
      };

      import-photos = pkgs.writeShellApplication {
        name = "import-photos";
        text = ''
          sudo mkdir -p /mnt/usbstick
          sudo mount -o uid=phil,gid=users /dev/sdb1 /mnt/usbstick

          mkdir -p /mnt/nas/Drive/Negatives/"$(date +%Y)"/"$(date +%m)"/

          mv --backup=numbered /mnt/usbstick/DCIM/100OLYMP/*.ORF /mnt/nas/Drive/Negatives/"$(date +%Y)"/"$(date +%m)"/

          sudo umount /mnt/usbstick
        '';
      };

      mnt-usb = pkgs.writeShellApplication {
        name = "mnt-usb";
        text = ''
          sudo mkdir -p /mnt/usbstick
          sudo mount -o uid=phil,gid=users /dev/sdb1 /mnt/usbstick
        '';
      };

      sync-notes = pkgs.writeShellApplication {
        name = "sync-notes";
        runtimeInputs = with pkgs; [ coreutils git openssh ];
        text = ''
          cd ~/notes

          if [[ $(git status --porcelain) ]]; then
            git stash save
            git pull --rebase
            git stash pop || true
            git add .
            git -c "user.name=Phil Kulak" -c "user.email=phil@kulak.us" commit -m "$(date)"
            git push origin main
          else
            git pull
          fi
        '';
      };
    in {
      home.packages = [
        import-photos
        mnt-usb
        sync-notes
        todo

        inputs.agenix.packages.${pkgs.system}.default
      ];

      programs.direnv.enable = true;

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

      xdg.configFile = {
        # Direnv
        "direnv/direnv.toml".text = ''
          [global]
          log_filter="^$"
          load_dotenv = true
          hide_env_diff = true
        '';

        # MPV
        "mpv/mpv.conf".text = "mute=yes";

        # Default Apps
        "mimeapps.list".text = ''
          [Default Applications]
          text/html=firefox.desktop
          x-scheme-handler/http=firefox.desktop
          x-scheme-handler/https=firefox.desktop

          image/gif=imv.desktop
          image/jpeg=imv.desktop
          image/png=imv.desktop
          image/heic=imv.desktop
          image/heif=imv.desktop
          image/webp=imv.desktop

          video/mp4=mpv.desktop
          video/avi=mpv.desktop
          video/mpeg=mpv.desktop
          video/wmv=mpv.desktop
          video/flv=mpv.desktop
          video/quicktime=mpv.desktop
          video/mp2t=mpv.desktop

          audio/ogg=mpv.desktop
          audio/opus=mpv.desktop
          audio/aac=mpv.desktop
          audio/flac=mpv.desktop
          audio/mpeg=mpv.desktop
          audio/mpa=mpv.desktop
          audio/wav=mpv.desktop

          application/pdf=org.pwmt.zathura-pdf-mupdf.desktop
        '';

        # XDG Dirs
        "user-dirs.dirs".text = ''
          XDG_DESKTOP_DIR="$HOME/Desktop"
          XDG_DOCUMENTS_DIR="$HOME/Documents"
          XDG_DOWNLOAD_DIR="$HOME/Downloads"
          XDG_MUSIC_DIR="$HOME/Music"
          XDG_PICTURES_DIR="$HOME/Pictures"
          XDG_PUBLICSHARE_DIR="$HOME/Public"
          XDG_TEMPLATES_DIR="$HOME/Templates"
          XDG_VIDEOS_DIR="$HOME/Videos"
        '';
      };
    };
}
