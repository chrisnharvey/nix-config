{
  fileSystems."/" =
    { device = "/dev/mapper/ROOT";
      fsType = "ext4";
      options = [ "defaults" "discard" "noatime" ];
    };

  boot.initrd.luks.devices."ROOT".device = "/dev/disk/by-label/CRYPT";

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ {
    device = "/swapfile";
    size = 32*1024;
  } ];
}
