{
  fileSystems."/" =
    { device = "/dev/mapper/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@" "compress" "ssd" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/mapper/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  boot.initrd.luks.devices."ROOT".device = "/dev/disk/by-label/CRYPT";

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ {
    device = "/swapfile";
    size = 16*1024;
  } ];
}
