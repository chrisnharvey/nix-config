{ config, lib, pkgs, ... }:
{
  # Bluetooth support
  hardware.bluetooth.enable = lib.mkDefault true;
  hardware.bluetooth.powerOnBoot = lib.mkDefault true;

  # PipeWire audio
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
  };

  # Firmware updates
  services.fwupd.enable = lib.mkDefault true;
}
