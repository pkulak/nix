{ self, inputs, ... }: {
  flake.nixosModules.packages = { config, pkgs, pkgs-unstable, ... }: {
    environment.systemPackages = with pkgs; [
      amber
      awscli2
      btop
      bc
      pkgs-unstable.claude-code
      cmatrix
      cowsay
      curl
      distrobox
      fastfetchMinimal
      ffmpeg-full
      ffmpegthumbnailer
      file
      gcc
      gocryptfs
      pkgs-unstable.gemini-cli
      glib
      httpie
      imv
      jq
      bind.dnsutils
      libinput
      lsd
      masterpdfeditor
      (mpv.override { scripts = [ mpvScripts.sponsorblock ]; })
      ripgrep
      serpl
      sublime-merge
      tldr
      unzip
      woeusb
      pkgs-unstable.yt-dlp
      zathura
      zenity
      zoom-us
      zoxide
    ];

    programs = {
      dconf.enable = true;
      seahorse.enable = true;
      ssh.startAgent = true;
    };

    services = {
      printing.enable = true;
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
      openssh = {
        enable = true;
        settings = { PasswordAuthentication = false; };
      };
      earlyoom = {
        enable = true;
        enableNotifications = true;
      };
      gnome = {
        gnome-keyring.enable = true;
        gcr-ssh-agent.enable = false;
      };
      flatpak.enable = true;
      tailscale.enable = true;
      resolved.enable = true;
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
