{ ... }:
{
  flake.nixosModules.garage-printer =
    { lib, ... }:
    {
      services.printing.enable = true;

      hardware.printers = {
        ensurePrinters = [
          {
            name = "Garage";
            description = "Garage";
            location = "Garage";
            deviceUri = "ipp://192.168.1.38:631/ipp/print";
            model = "everywhere";
            ppdOptions = {
              "printer-is-shared" = "false";
              "job-sheets-default" = "none,none";
              "media-default" = "na_letter_8.5x11in";
              "sides-default" = "one-sided";
            };
          }
        ];
        ensureDefaultPrinter = lib.mkDefault "Garage";
      };
    };
}
