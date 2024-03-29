# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0d4b0f35-e187-455c-b97d-aa7a203e500d";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  boot.initrd.luks.devices."luks-c1e64d42-0251-4019-a975-0f687633c00f".device = "/dev/disk/by-uuid/c1e64d42-0251-4019-a975-0f687633c00f";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AD7B-A652";
      fsType = "vfat";
    };

  fileSystems."/var/lib/docker/btrfs" =
    { device = "/@/var/lib/docker/btrfs";
      fsType = "none";
      options = [ "bind" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
  # networking.interfaces.tailscale0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
