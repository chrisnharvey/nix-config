{
  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
      options = [ "defaults" "discard" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

#  swapDevices = [ {
#    device = "/var/lib/swapfile";
#    size = 16*1024;
#    randomEncryption.enable = true; 
#  } ];
}