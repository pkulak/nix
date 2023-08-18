{ config, pkgs, pkgs-unstable, ... }:

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
      curl
      exa
      distrobox
      ffmpeg
      ffmpegthumbnailer
      file
      firefox
      gcc
      git
      glib
      gocryptfs
      imv
      libsForQt5.kdialog
      (mpv.override { scripts = [ mpvScripts.sponsorblock ]; })
      networkmanagerapplet
      podman
      ripgrep
      sublime-merge
      tldr
      unzip
      woeusb
      xfce.thunar
      xfce.tumbler
      yt-dlp
      zathura

      (callPackage ./matui (lib.trivial.mergeAttrs pkgs { inherit pkgs-unstable; }))
      (callPackage ./pgen pkgs)
    ];

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
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA2lQGc0oA11Lgo+C3Mo9gYAWsvv/G3vA5lGoHISJ5mGLGZEcFol7coxVjtzkoWE1k0blwGPUwc1aDMwCz7Nmz5nD8GLl9J3OLi3YynmsQAiqM07D/RPLq7YqtkDOLTIwTbBV6SpX+ytw/hLT8LnWen4VwIDHPTzWMrirTGJK5BFD7jEXhHFS/ZSgoxYqA5rie3GrJ7JK/Wy7/+rJjD/JSaswcefVi5aESXJQS2aur2HYK90ZeG+YdYL7+NNYdfapz3BFgIjTf8SAOlo9NN3NSUjb58HdtCWLNRMfji/fEdy0WsA0I4/mMxBqih9zb2TWsyDj0tp6IYyVlmOpIKdKkgQ== phil@fry" ];
    };

    virtualisation.containers.enable = true;

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
      enableDefaultFonts = true;
      fonts = with pkgs; [ 
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
