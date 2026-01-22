{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [ ./1password.nix ./snapper.nix ./smb.nix ./niri.nix ./rust.nix ];

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
    ffmpeg-full
    ffmpegthumbnailer
    file
    gcc
    git
    ghostty
    glib
    gocryptfs
    httpie
    imv
    jq
    jujutsu
    kdePackages.kdialog
    libinput
    lsd
    masterpdfeditor
    matui
    (mpv.override { scripts = [ mpvScripts.sponsorblock ]; })
    ripgrep
    rmpc
    serpl
    sublime-merge
    tldr
    unzip
    woeusb
    pkgs-unstable.yt-dlp
    zathura
    zoom-us
    zoxide

    (callPackage ./pgen pkgs)
    (callPackage ./pixlet.nix pkgs)
  ];

  environment.etc = with pkgs; {
    "jdk17".source = jdk17;
    "jdk11".source = jdk11;
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
  };

  programs = {
    fish.enable = true;
    dconf.enable = true;
    seahorse.enable = true;
    ssh.startAgent = true;
  };

  # use resolvd
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  security = {
    polkit.enable = true;
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

  # Tailscale stuffs
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
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
}
