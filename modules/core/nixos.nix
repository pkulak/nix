{ self, inputs, ... }:
{
  flake.nixosModules.core =
    {
      config,
      host,
      pkgs,
      ...
    }:
    {
      boot.loader.grub.enable = true;
      boot.loader.grub.efiSupport = true;
      boot.loader.grub.device = "nodev";
      boot.loader.grub.useOSProber = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.supportedFilesystems = [ "ntfs" ];
      boot.kernelParams = [ "rd.luks.options=discard" ];

      fileSystems = {
        "/".options = [
          "compress-force=zstd"
          "autodefrag"
        ];
        "/home".options = [
          "compress-force=zstd"
          "autodefrag"
        ];
        "/nix".options = [
          "compress-force=zstd"
          "noatime"
          "nodiratime"
          "autodefrag"
        ];
        "/swap".options = [
          "noatime"
          "nodiratime"
        ];
      };

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

      nix.settings.trusted-users = [
        "root"
        "phil"
      ];

      nixpkgs = {
        config.allowUnfree = true;
        overlays = [
          inputs.nur.overlays.default
          (final: prev: {
            inherit (inputs.matui.packages.${prev.stdenv.hostPlatform.system}) matui;
            unstable = import inputs.nixpkgs-unstable {
              inherit (prev.stdenv.hostPlatform) system;
              config.allowUnfree = true;
            };
          })
        ];
      };

      environment.systemPackages = with pkgs; [
        btop
        curl
        neovim
        ripgrep
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

      system.stateVersion = "23.05";

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

      imports = [ inputs.home-manager.nixosModules.home-manager ];

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
