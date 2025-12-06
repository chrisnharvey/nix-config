{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Quiet boot
  boot.plymouth.enable = lib.mkDefault true;
  boot.initrd.systemd.enable = lib.mkDefault true;
  boot.initrd.verbose = lib.mkDefault false;
  boot.consoleLogLevel = lib.mkDefault 0;

  # Systemd-boot
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.timeout = lib.mkDefault 3;

  # Common kernel parameters for quiet boot
  boot.kernelParams = lib.mkDefault [
    "quiet"
    "udev.log_level=0"
  ];
}
