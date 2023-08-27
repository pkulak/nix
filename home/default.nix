{ config, pkgs, host, ... }:

let
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

      if [[ ''$(git status --porcelain) ]]; then
	      git stash save
	      git pull --rebase
	      git stash pop
	      git add .
	      git commit -m "''$(date)"
	      git push origin main
      else
	      git pull
      fi
    '';
  };

  rebuild = pkgs.writeShellApplication {
    name = "rebuild";
    text = "sudo nixos-rebuild --flake ~/nix/#${host} switch";
  };

  update = pkgs.writeShellApplication {
    name = "update";
    text = ''
      cd ~/nix
      nix flake update -I ~/nix
      ${rebuild}/bin/rebuild
      cd "$OLDPWD"
    '';
  };
in {
  imports = [
    ./alacritty.nix
    ./astronvim
    ./sway
    ./waybar
    ./wofi

    ./hosts/${host}.nix
  ];

  home.packages = [
    import-photos
    mnt-usb
    rebuild
    sync-notes
    update
  ];

  home.username = "phil";
  home.homeDirectory = "/home/phil";

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
    # Beets
    "beets/config.yaml".text = ''
      directory: /mnt/music
      plugins: fetchart replaygain

      replaygain:
        backend: ffmpeg

      paths:
        default: $albumartist/$album%aunique{}/$track - $title
        singleton: Non-Album/$artist/$title
        comp: Compilations/$album%aunique{}/$track - $title
    '';

    # Fish
    "fish/config.fish".text = ''
      fish_vi_key_bindings
      set fish_greeting

      alias ls 'ls -tr --color=auto'
      alias .. 'cd ..'
      alias ... 'cd ../..'
      alias md 'mkdir -p'
      alias sm 'smerge .'
      alias ssh 'TERM=xterm-256color command ssh'
      alias c clear
      alias za zathura
      alias ts 'date -u +"%Y-%m-%dT%H:%M:%SZ"'
      alias l 'exa --long --all --links --git --sort mod'
      alias bc 'bc -lq'
      alias rs 'rsync -avH --info=progress2'
      alias dr '${pkgs.ripdrag}/bin/ripdrag -a'
      alias screencast '${pkgs.wf-recorder}/bin/wf-recorder -g (${pkgs.slurp}/bin/slurp)'
      alias mnt-private 'mkdir -p ~/private && ${pkgs.gocryptfs}/bin/gocryptfs -noprealloc ~/notes/private ~/private'
    '';

    "fish/functions/compress.fish".text = ''
      function compress --wraps=tar
        tar -czf (basename $argv).tar.gz $argv
      end
    '';

    "fish/functions/extract.fish".text = ''
      function extract --wraps tar
        tar -xvf $argv
      end
    '';

    # Mako
    "mako/config".text = "font=monospace 12";

    # Matui
    "matui/config.toml".text = ''
      reactions = ["👍️", "😂", "❤️", "👎", "‼️", "❓️", "🙁", "🚀", "🤣", "👆"]
      muted = ["!hMPITSQBLFEleSJmVm:kulak.us", "!zCIiPpUbrNESgmegGW:kulak.us"]
      clean_vim = true
    '';

    # MPV
    "mpv/mpv.conf".text = "mute=yes";

    # Default Apps
    "mimeapps.list".text = ''
      [Default Applications]
      text/html=firefox.desktop
      x-scheme-handler/http=firefox.desktop
      x-scheme-handler/https=firefox.desktop

      image/gif=swayimg.desktop
      image/jpeg=swayimg.desktop
      image/png=swayimg.desktop

      video/mp4=mpv.desktop
      video/quicktime=mpv.desktop

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

  home.file = {
    # IntelliJ
    ".ideavimrc".text = ''
      set ignorecase
      set smartcase
      set relativenumber
      set number
      inoremap jj <esc>
      set visualbell
    '';

    # Vevo
    "vevo/.envrc".text = ''
      export GIT_AUTHOR_EMAIL="phil.kulak@vevo.com"
    '';
  };

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}
