{ config, pkgs, host, ... }:

{
  imports = [
    ./alacritty.nix
    ./astronvim.nix
    ./sway
    ./waybar
    ./wofi

    ./hosts/${host}.nix
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

    # Ranger
    "ranger/rc.conf".text = "map <C-d> shell ${pkgs.xdragon}/bin/dragon -a -x %p";
  };

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}
