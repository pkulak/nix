{ config, pkgs, ... }:

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
    win-virtio
    win-spice
  ];

  # the firewall screws up Virt-Manger; disable on that interface
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # Manage the virtualisation services
  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
