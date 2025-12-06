{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable CUPS printing
  services.printing.enable = lib.mkDefault true;
  services.printing.drivers = lib.mkDefault [ pkgs.hplip ];

  # Common printer configuration
  hardware.printers = lib.mkDefault {
    ensurePrinters = [
      {
        name = "Office_Printer";
        location = "Office";
        deviceUri = "socket://192.168.30.20";
        model = "drv:///hp/hpcups.drv/hp-deskjet_2540_series.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Office_Printer";
  };

  # Scanner support
  hardware.sane.enable = lib.mkDefault true;
  hardware.sane.extraBackends = lib.mkDefault [ pkgs.hplipWithPlugin ];
}
