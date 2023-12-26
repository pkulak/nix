{ config, pkgs, ... }:

{
  imports = [ 
    ./snapper.nix
    ./smb.nix
    ./sublime-music.nix
    ./sway.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      age
      btop
      bc
      beets
      cinnamon.nemo-with-extensions
      chromium
      curl
      distrobox
      ffmpeg
      ffmpegthumbnailer
      file
      gcc
      git
      glib
      gocryptfs
      httpie
      imv
      libsForQt5.kdialog
      lsd
      (mpv.override { scripts = [ mpvScripts.sponsorblock ]; })
      ripgrep
      unstable.sublime-merge
      tldr
      unzip
      woeusb
      yt-dlp
      zathura
      zoom-us

      (callPackage ./matui pkgs)
      (callPackage ./pgen pkgs)
    ];

    environment.etc = with pkgs; {
      "jdk11".source = jdk11;
      "jdk17".source = jdk17;
      "chromedriver".source = chromedriver;
    };

    # Udev rule for game controllers
    services.udev.packages = [ (pkgs.callPackage ./game-devices.nix pkgs) ];

    # Tame the proxy a bit to let Wireguard work
    networking.firewall.checkReversePath = false;

    # Allow users to nice down to -10
    security.pam.loginLimits = [
      { domain = "phil"; type = "-"; item = "nice"; value = "-10"; }
      { domain = "phil"; type = "-"; item = "nofile"; value = "1048576"; }
    ];

    # Printing is nice
    services.printing.enable = true;
    services.avahi.enable = true;
    services.avahi.nssmdns = true;
    services.avahi.openFirewall = true;

    security.polkit.enable = true;
    programs.fish.enable = true;
    services.flatpak.enable = true;

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };

    users.users.phil = {
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C" ];
    };

    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };

    virtualisation.podman.enable = true;

    nix = {
      settings = {
        warn-dirty = false;
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    fonts = {
      enableDefaultPackages = true;

      packages = with pkgs; [ 
        cantarell-fonts
        font-awesome
        (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        ubuntu_font_family
      ];

      fontconfig = {
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Cantarell" ];
          monospace = [ "Ubuntu Mono" ];
        };
      };
    };
  };
}
