{ ... }: {
  networking.hostName = "barnaby";
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.efi.canTouchEfiVariables = false;
}
