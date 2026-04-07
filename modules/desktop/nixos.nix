{ self, inputs, ... }: {
  flake.nixosModules.desktop = { config, pkgs, ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        neovim = self.packages.${prev.stdenv.hostPlatform.system}.neovim;
      })
    ];
    environment.systemPackages = with pkgs; [
      (mpv.override { scripts = [ mpvScripts.sponsorblock ]; })

      amber
      awscli2
      bc
      bind.dnsutils
      cmatrix
      cowsay
      distrobox
      fastfetchMinimal
      ffmpeg-full
      ffmpegthumbnailer
      file
      gcc
      glib
      gocryptfs
      imv
      jq
      libinput
      lsd
      masterpdfeditor
      claude-code
      unstable.gemini-cli
      unstable.yt-dlp
      serpl
      sublime-merge
      tldr
      unzip
      woeusb
      xh
      zathura
      zenity
      zoom-us
      zoxide
    ];

    programs = {
      dconf.enable = true;
      seahorse.enable = true;
    };

    services = {
      printing.enable = true;
      earlyoom = {
        enable = true;
        enableNotifications = true;
      };
      gnome = {
        gnome-keyring.enable = true;
        gcr-ssh-agent.enable = false;
      };
      flatpak.enable = true;
    };

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        cantarell-fonts
        font-awesome
        nerd-fonts.fantasque-sans-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        ubuntu-classic
      ];
      fontconfig = {
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Cantarell" ];
          monospace = [ "Ubuntu Mono" ];
        };
      };
    };

    environment.etc = with pkgs; {
      "jdk17".source = jdk17;
      "jdk11".source = jdk11;
    };

    virtualisation = {
      docker.rootless = {
        enable = true;
        setSocketVariable = true;
      };
      podman.enable = true;
    };
  };
}
