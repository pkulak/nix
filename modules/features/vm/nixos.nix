{ pkgs, ... }:

{
  # Enable dconf (System Management Tool)
  programs.dconf.enable = true;

  # Add user to libvirtd group
  users.users.phil.extraGroups = [ "libvirtd" ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
  ];

  # Manage the virtualisation services
  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };

    spiceUSBRedirection.enable = true;
  };
}
