{ ... }: {
  services.spice-vdagentd.enable = true;
  networking.hostName = "kvm";
}
