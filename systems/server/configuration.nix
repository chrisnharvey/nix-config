# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
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

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [
    "data"
    "vms"
  ];
  boot.zfs.requestEncryptionCredentials = false;
  services.zfs.autoScrub.enable = true;

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    flake = "github:chrisnharvey/nix-config";
    dates = "20:00";
  };

  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  services.syncthing = {
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
      restic.enable = true;
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

  networking.hostId = "c1613a14";
  networking.hostName = "server"; # Define your hostname.
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
  networking.interfaces.br0.useDHCP = true;
  networking.bridges.br0.interfaces = [ "enp0s31f6" ];

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "uk";

  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.chris = {
    isNormalUser = true;
    description = "Chris";
    extraGroups = [
      "networkmanager"
      "docker"
      "wheel"
      "libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgZSwNSFRZk2XJBT6PXdeQdYJEUAYdhYZCtfcPwPtLt chris@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAcJtjf0vG9Morw29uV4h7y+lnIjxQqzkTonvNncXld6 chris@steamdeck"
    ];
    packages = with pkgs; [ ];
  };

  users.groups.virt = { };
  users.users.virt = {
    isSystemUser = true;
    useDefaultShell = true;
    group = "virt";
    extraGroups = [ "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIId9wLxRIEy+It8TS6NlLpu/Bg0ug7JivClWZusQUF4x root@adde2bbe3d25"
    ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  pkgs.k3s
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # msedit
    pciutils
    inxi
    killall
    linuxPackages_latest.perf
    fwts
    wget
    git
    tailscale
    smartmontools
    htop
    tmux
    zoxide
    borgbackup
    powertop
    rs-tftpd
    (pkgs.writeScriptBin "start-homelab" (builtins.readFile ./scripts/start-homelab.sh))
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  #services.k3s.enable = true;
  #services.k3s.role = "server";

  programs.zsh.enable = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.allowedBridges = [ "br0" ];
  virtualisation.libvirtd.onShutdown = "shutdown";
  virtualisation.libvirtd.onBoot = "ignore";

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;
  virtualisation.docker.storageDriver = "zfs";
  virtualisation.docker.daemon.settings = {
    data-root = "/vms/docker";
    default-address-pools = [
      {
        base = "172.17.0.0/12";
        size = 24;
      }
    ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 6443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
