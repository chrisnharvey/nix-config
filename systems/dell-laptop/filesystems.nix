{
  fileSystems."/" =
    { device = "/dev/mapper/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@" "ssd" "compress=zstd" ];
    };

  fileSystems."/nix" =
    { device = "/dev/mapper/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@nix" "ssd" "compress=zstd" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/mapper/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@home" "ssd" "compress=zstd" ];
    };

  fileSystems."/swap" =
    { device = "/dev/mapper/ROOT";
      fsType = "btrfs";
      options = [ "subvol=@swap" "ssd" "noatime" "nodatacow" "nodatasum" "compress=none" "compress-force=none" ];
    };


  boot.initrd.luks.devices."ROOT".device = "/dev/disk/by-label/CRYPT";

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ {
    device = "/swap/swapfile";
    size = 32*1024;
  } ];
}