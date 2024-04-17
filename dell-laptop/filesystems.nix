{
  fileSystems."/" =
    { device = "/dev/mapper/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/home" =
    { device = "/dev/mapper/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  boot.initrd.luks.devices."ROOT".device = "/dev/disk/by-uuid/c1e64d42-0251-4019-a975-0f687633c00f";

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ {
    device = "/swapfile";
    size = 32*1024;
  } ];}
