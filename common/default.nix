{ pkgs, ... }:

{
  imports = [ ./snapper.nix ./smb.nix ./river.nix ./rust.nix ];

  config = {
    environment.systemPackages = with pkgs; [
      age
      awscli2
      btop
      bc
      beets
      cmatrix
      cowsay
      nemo-with-extensions
      curl
      distrobox
      fastfetchMinimal
      ffmpeg
      ffmpegthumbnailer
      file
      filtile
      foot
      gcc
      git
      glib
      gocryptfs
      httpie
      imv
      unstable.jujutsu
      libsForQt5.kdialog
      lsd
      matui
      (mpv.override { scripts = [ mpvScripts.sponsorblock ]; })
      ripgrep
      unstable.rmpc
      sublime-merge
      tldr
      unzip
      woeusb
      unstable.yt-dlp
      zathura
      zoom-us
      zoxide

      (callPackage ./pgen pkgs)
      (callPackage ./pixlet.nix pkgs)
    ];

    environment.etc = with pkgs; {
      "jdk11".source = jdk11;
      "jdk17".source = jdk17;
    };

    services = {
      # Udev rule for game controllers
      udev.packages = [ (pkgs.callPackage ./game-devices.nix pkgs) ];

      # Printing is nice
      printing.enable = true;

      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      flatpak.enable = true;

      gnome.gnome-keyring.enable = true;

      openssh = {
        enable = true;
        settings = { PasswordAuthentication = false; };
      };

      earlyoom = {
        enable = true;
        enableNotifications = true;
      };

      tailscale.enable = true;
    };

    programs = {
      fish.enable = true;
      dconf.enable = true;
      seahorse.enable = true;
      ssh.startAgent = true;
    };

    # Tame the proxy a bit to let Wireguard work
    networking.firewall.checkReversePath = false;

    security = {
      polkit.enable = true;
      pam.services.gnomekey.enableGnomeKeyring = true;
    };

    users.users.phil = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C"
      ];
    };

    virtualisation = {
      docker.rootless = {
        enable = true;
        setSocketVariable = true;
      };

      podman.enable = true;
    };

    nix = {
      settings = {
        warn-dirty = false;
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
        download-buffer-size = 500000000; # 500 MB;
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };

    fonts = {
      enableDefaultPackages = true;

      packages = with pkgs; [
        cantarell-fonts
        font-awesome
        nerd-fonts.fantasque-sans-mono
        noto-fonts
        noto-fonts-cjk-sans
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
