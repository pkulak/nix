{ self, inputs, ... }:
{
  flake.nixosModules.core =
    {
      config,
      host,
      lib,
      pkgs,
      ...
    }:
    {
      boot.loader.grub.enable = true;

      # EFI by default; override in the host for BIOS.
      boot.loader.grub.efiSupport = lib.mkDefault true;
      boot.loader.grub.device = lib.mkDefault "nodev";
      boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

      networking.networkmanager.enable = true;
      time.timeZone = "America/Los_Angeles";
      hardware.graphics.enable = true;

      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };
      };

      users.users.phil = {
        isNormalUser = true;
        description = "Phil";
        extraGroups = [
          "libvirtd"
          "networkmanager"
          "wheel"
          "video"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C"
        ];
        hashedPassword = "$6$FyNPgBac91py3OFQ$6v4B2x7NOlHH.ZqG1eCw4Gd5GWTkYJZeB9vi/2xr8H6zqlkzfvahzFhhCl6MbuSfpvUm4RCV6UkJSkmiHaT6/0";
      };

      services.getty.autologinUser = "phil";

      nix.settings = {
        trusted-users = [
          "root"
          "phil"
        ];

        # llm-agents
        extra-substituters = [ "https://cache.numtide.com" ];
        extra-trusted-public-keys = [
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };

      age.identityPaths = [ "/home/phil/.ssh/id_ed25519" ];

      nixpkgs = {
        config.allowUnfree = true;
        overlays = [
          inputs.nur.overlays.default
          inputs.llm-agents.overlays.default
          (final: prev: {
            inherit (inputs.matui.packages.${prev.stdenv.hostPlatform.system}) matui;
            neovim = self.packages.${prev.stdenv.hostPlatform.system}.neovim;
            ffmpeg-over-ip-client = self.packages.${prev.stdenv.hostPlatform.system}.ffmpeg-over-ip-client;
            ffmpeg-over-ip = self.packages.${prev.stdenv.hostPlatform.system}.ffmpeg-over-ip;
            unstable = import inputs.nixpkgs-unstable {
              inherit (prev.stdenv.hostPlatform) system;
              config.allowUnfree = true;
            };
          })
        ];
      };

      environment.systemPackages = with pkgs; [
        awscli2
        bc
        bind.dnsutils
        btop
        curl
        ffmpeg-full
        gcc
        glib
        gocryptfs
        jq
        loudgain
        lsd
        neovim

        (python3.withPackages (
          ps: with ps; [
            requests
            beautifulsoup4
            python-dateutil
          ]
        ))

        ripgrep
        serpl
        serpl
        tldr
        yt-dlp
        unzip
        xh
      ];

      programs = {
        ssh.startAgent = true;
      };

      services = {
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
        openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
          };
        };
        tailscale.enable = true;
        resolved.enable = true;
      };

      networking.networkmanager.dns = "systemd-resolved";
      security.polkit.enable = true;

      networking.firewall = {
        enable = true;
        checkReversePath = "loose";
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };

      nix = {
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        registry.nixpkgs.flake = inputs.nixpkgs;
        settings = {
          warn-dirty = false;
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          download-buffer-size = 500000000;
        };
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 14d";
        };
      };

      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.agenix.nixosModules.default
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        extraSpecialArgs = {
          inherit host;
        };

        sharedModules = [
          inputs.agenix.homeManagerModules.default
        ];
      };
    };
}
