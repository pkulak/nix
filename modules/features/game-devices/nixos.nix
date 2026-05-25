{ pkgs, ... }:
{
  services = {
    udev = {
      packages = with pkgs; [
        game-devices-udev-rules
        (writeTextDir "lib/udev/rules.d/70-keychron-q4.rules" ''
          # Keychron Q4; allow VIA/WebHID access to the keyboard's hidraw interfaces.
          ACTION!="remove", KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0140", MODE="0660", TAG+="uaccess"
        '')
      ];
    };
  };

  hardware.uinput.enable = true;
}
