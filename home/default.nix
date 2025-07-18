{ agenix, config, pkgs, host, system, ... }:

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

  clean = pkgs.writeShellApplication {
    name = "clean";
    runtimeInputs = with pkgs; [ moreutils ];
    text = ''
      tmux list-sessions | grep -v "(attached)"
      tmux list-sessions | grep -v "(attached)" | awk 'BEGIN{FS=":"}{print $1}' \
        | ifne xargs -n 1 tmux kill-session -t
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

  rebuild = pkgs.writeShellApplication {
    name = "rebuild";
    text = "sudo nixos-rebuild --flake ~/nix/#${host} switch";
  };

  update = pkgs.writeShellApplication {
    name = "update";
    text = ''
      cd ~/nix
      nix flake update -I ~/nix
      cd "$OLDPWD"
    '';
  };

  public-key =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C phil@kulak.us";
in {
  imports = [
    ./firefox.nix
    ./fish.nix
    ./git.nix
    ./jj
    ./mpd
    ./river
    ./secrets
    ./tmux.nix
    ./waybar
    ./wofi

    ./hosts/${host}.nix
  ];

  home = {
    username = "phil";
    homeDirectory = "/home/phil";

    packages = [
      clean
      import-photos
      mnt-usb
      rebuild
      sync-notes
      todo
      update

      agenix.packages.${system}.default
      pkgs.nvix
    ];
  };

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

    # Direnv
    "direnv/direnv.toml".text = ''
      [global]
      load_dotenv = true
      hide_env_diff = true
    '';

    # Mako
    "mako/config".text = ''
      font=monospace 12

      background-color=#181825
      text-color=#cdd6f4
      border-color=#94e2d5
      progress-color=over #313244

      [urgency=high]
      border-color=#fab387
    '';

    # Matui
    "matui/config.toml".text = ''
      reactions = ["👍️", "😂", "😘", "❤️", "👎", "‼️", "❓️", "🙁", "🚀", "🤣", "👆", "😱"]
      muted = ["!hMPITSQBLFEleSJmVm:kulak.us", "!zCIiPpUbrNESgmegGW:kulak.us"]
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

      video/mp4=mpv.desktop
      video/avi=mpv.desktop
      video/mpeg=mpv.desktop
      video/wmv=mpv.desktop
      video/flv=mpv.desktop
      video/quicktime=mpv.desktop
      video/mp2t=mpv.desktop

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

    # Foot Terminal
    "foot/foot.ini".source = ./foot.ini;
  };

  home.file = {
    # Firefox
    ".mozilla/native-messaging-hosts/ff2mpv.json".source =
      "${pkgs.ff2mpv}/lib/mozilla/native-messaging-hosts/ff2mpv.json";

    # IntelliJ
    ".ideavimrc".text = ''
      set ignorecase
      set smartcase
      set relativenumber
      set number
      inoremap jj <esc>
      set visualbell
    '';

    # SSH
    ".ssh/allowed_signers".text = "* ${public-key}";
    ".ssh/id_ed25519.pub".text = public-key;
  };

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}
