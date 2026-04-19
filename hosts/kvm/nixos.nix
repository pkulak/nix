{ ... }: {
  services.spice-vdagentd.enable = true;
  networking.hostName = "kvm";
  system.stateVersion = "23.05";
}
