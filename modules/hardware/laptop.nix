{ config, lib, pkgs, ... }:
{
  # Power management for laptops
  powerManagement.enable = lib.mkDefault true;

  # Hibernation support
  security.protectKernelImage = lib.mkDefault false;

  # UPower for battery management
  services.upower.enable = lib.mkDefault true;
  services.upower.criticalPowerAction = lib.mkDefault "Hibernate";

  # Quiet boot
  boot.plymouth.enable = lib.mkDefault true;
  boot.initrd.systemd.enable = lib.mkDefault true;
  boot.initrd.verbose = lib.mkDefault false;
  boot.consoleLogLevel = lib.mkDefault 0;

  # Systemd-boot
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  boot.loader.timeout = lib.mkDefault 0;

  # Common kernel parameters for quiet boot
  boot.kernelParams = lib.mkDefault [
    "quiet"
    "udev.log_level=0"
  ];

  # TPM2 support
  security.tpm2.enable = lib.mkDefault true;
  security.tpm2.pkcs11.enable = lib.mkDefault true;
  security.tpm2.tctiEnvironment.enable = lib.mkDefault true;
}
