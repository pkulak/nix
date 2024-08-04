{ pkgs, ... }:

{
  imports = [
    ./snapper.nix
    ./smb.nix 
    ./river.nix
    ./rust.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      age
      alacritty
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
      filtile
      gcc
      git
      glib
      gocryptfs
      httpie
      imv
      libsForQt5.kdialog
      lsd
      matui
      nixvim
      (mpv.override { scripts = [ mpvScripts.sponsorblock ]; })
      ripgrep
      sublime-merge
      supersonic-wayland
      tldr
      unzip
      woeusb
      yt-dlp
      zathura
      zoom-us
      zoxide

      (callPackage ./pgen pkgs)
      (callPackage ./pixlet.nix pkgs)
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

    # Printing is nice
    services.printing.enable = true;
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;
    services.avahi.openFirewall = true;

    security.polkit.enable = true;
    programs.fish.enable = true;
    programs.dconf.enable = true;
    programs.seahorse.enable = true;
    services.flatpak.enable = true;

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gnomekey.enableGnomeKeyring = true;

    programs.ssh.startAgent = true;

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
