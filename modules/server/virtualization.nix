{ config, lib, pkgs, ... }:
{
  # Virtualization configuration for server
  virtualisation.libvirtd = lib.mkDefault {
    enable = true;
    allowedBridges = [ "br0" ];
    onShutdown = "shutdown";
    onBoot = "ignore";
  };

  virtualisation.docker = lib.mkDefault {
    enable = true;
    enableOnBoot = false;
    storageDriver = "zfs";
    logDriver = "json-file";
    daemon.settings = {
      data-root = "/vms/docker";
      default-address-pools = [
        {
          base = "172.17.0.0/12";
          size = 24;
        }
      ];
    };
  };
}
