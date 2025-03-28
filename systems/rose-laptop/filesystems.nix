{
  fileSystems."/" =
    { device = "/dev/disk/by-label/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-label/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  # swapDevices = [ {
  #   device = "/swapfile";
  #   size = 32*1024;
  # } ];
}
