{ ... }: {
  services.spice-vdagentd.enable = true;
  networking.hostName = "kvm";

  boot.kernelModules = [ "virtio-gpu" ];
}
