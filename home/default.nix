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
    rebuild
    update
  ];

  home.username = "phil";
  home.homeDirectory = "/home/phil";

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
      alias dr 'dragon-drop -a -x'
      alias screencast '${pkgs.wf-recorder}/bin/wf-recorder -g (${pkgs.slurp}/bin/slurp)'
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

    # Ranger
    "ranger/plugins/ranger_devicons" = {
      source = pkgs.fetchFromGitHub {
        owner = "alexanderjeurissen";
        repo = "ranger_devicons";
        rev = "1b5780117eeebdfcd221ce45823a1ddef8399848";
        sha256 = "sha256-MMPbYXlSLwECf/Li4KqYbSmKZ8n8LfTdkOfZKshJ30w=";
      };
    };

    "ranger/rc.conf".text = ''
      map <C-d> shell ${pkgs.xdragon}/bin/dragon -a -x %p
      default_linemode devicons
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
  };

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}
