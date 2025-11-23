# Server NixOS Configuration
# Home server with ZFS, NFS, Samba, Docker, and various services

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Server-specific modules
    ../../modules/server

    # Hardware configuration
    ./hardware-configuration.nix
    ./filesystems.nix
    ./backup.nix
    ./duplicacy-web
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "selinux=0"
  ];
  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = "8192";
    "fs.inotify.max_user_watches" = "1048576";
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [
    "data"
    "vms"
  ];
  boot.zfs.requestEncryptionCredentials = false;
  services.zfs.autoScrub.enable = true;

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    flake = "github:chrisnharvey/nix-config";
    dates = "20:00";
  };

  # Syncthing
    enable = true;
    guiAddress = "192.168.10.9:8384";
    user = "chris";
    dataDir = "/data/data/files/Chris/Documents";
    configDir = "/data/data/files/Chris/.config/syncthing";
  };

  services.sanoid = {
    enable = true;

    datasets = {
      "data/data" = {
        recursive = true;
        daily = 14;
        hourly = 24;
        monthly = 3;
        autosnap = true;
        autoprune = true;
      };
      "vms/data" = {
        recursive = true;
        daily = 14;
        hourly = 24;
        monthly = 3;
        autosnap = true;
        autoprune = true;
      };
    };
  };

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.prometheus = {
    enable = false;
    exporters = {
      node.enable = true;
      zfs.enable = true;
      libvirt.enable = true;
      smartctl.enable = true;
      process = {
        enable = true;
        settings.process_names = [
          {
            name = "{{.ExeFull}}";
            cmdline = [ ".+" ];
          }
        ];
      };
    };
  };

  services.telegraf.enable = true;
  services.telegraf.extraConfig.inputs = {
    mem = { };
    processes = { };
    swap = { };
    system = { };
    zfs = {
      poolMetrics = true;
      datasetMetrics = true;
    };
    cpu = {
      percpu = true;
      totalcpu = true;
      collect_cpu_time = false;
      report_active = false;
      core_tags = false;
    };
    disk = {
      ignore_fs = [
        "tmpfs"
        "devtmpfs"
        "devfs"
        "iso9660"
        "overlay"
        "aufs"
        "squashfs"
      ];
    };
    diskio = { };
    kernel = { };
  };
  services.telegraf.extraConfig.outputs.prometheus_client = {
    listen = ":9273";
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    "/data/data/files/HomeAssistant" 192.168.10.11(rw,sync,no_subtree_check,no_root_squash)
    "/data/data/files/Share" 192.168.10.0/24(rw,sync,no_subtree_check,no_root_squash)
    "/data/data" *(rw,sync,no_subtree_check,no_root_squash)
  '';

  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global.security = "user";
      Share = {
        path = "/data/data/files/Share";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "chris";
        "force group" = "users";
      };
      Data = {
        path = "/data/data";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "force user" = "chris";
        "force group" = "users";
        "write list" = "";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  host.services.duplicacy-web.enable = true;
  host.services.duplicacy-web.autostart = false;
  host.services.duplicacy-web.environment = "/data/data/duplicacy-environment";

  # Networking - server-specific settings
  networking.hostId = "c1613a14";
  networking.hostName = "server";
  
  # VLANs
  networking.vlans.vlan15 = {
    id = 15;
    interface = "br0";
  };
  networking.vlans.vlan40 = {
    id = 40;
    interface = "br0";
  };
  networking.vlans.vlan50 = {
    id = 50;
    interface = "br0";
  };
  
  # Bridge configuration
  networking.interfaces.br0.useDHCP = true;
  networking.bridges.br0.interfaces = [ "enp0s31f6" ];

  # Server-specific packages
  environment.systemPackages = with pkgs; [
    pciutils
    inxi
    killall
    linuxPackages_latest.perf
    fwts
    wget
    git
    smartmontools
    htop
    tmux
    zoxide
    borgbackup
    powertop
    rs-tftpd
    (pkgs.writeScriptBin "start-homelab" (builtins.readFile ./scripts/start-homelab.sh))
  ];

  # Firewall configuration
  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.enable = false;

  system.stateVersion = "23.11";
}
