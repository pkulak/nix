{ matui, filtile, pkgs-unstable, nur, nvix, ... }:

{
  imports = [ ./common ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelParams = [ "rd.luks.options=discard" ];

  fileSystems = {
    "/".options = [ "compress-force=zstd" "autodefrag" ];
    "/home".options = [ "compress-force=zstd" "autodefrag" ];
    "/nix".options =
      [ "compress-force=zstd" "noatime" "nodiratime" "autodefrag" ];
    "/swap".options = [ "noatime" "nodiratime" ];
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.phil = {
    isNormalUser = true;
    description = "Phil";
    extraGroups = [ "libvirtd" "networkmanager" "wheel" "video" ];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "phil";

  nix.settings.trusted-users = [ "root" "phil" ];

  nixpkgs = {
    # Allow unfree packages
    config.allowUnfree = true;

    # Overlay some stuff
    overlays = [
      nur.overlays.default
      (final: prev: {
        inherit (matui.packages.${prev.stdenv.system}) matui;
        inherit (filtile.packages.${prev.stdenv.system}) filtile;
        nvix = nvix.packages.${prev.stdenv.system}.core;
        unstable = pkgs-unstable;
      })
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
