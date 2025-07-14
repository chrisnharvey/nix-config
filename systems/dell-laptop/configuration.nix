# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./filesystems.nix
      ../../desktops/gnome.nix # Include the GNOME Desktop Environment.
      #../../desktops/plasma.nix # Include the Plasma Desktop Environment.
    ];

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];

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

  services.udisks2.settings = {
    "udisks2.conf" = {
        defaults = {
            sync = true;
        }
    }
  }

  powerManagement.enable = true;

  # required for hibernation
  security.protectKernelImage = false;

  services.logind.lidSwitch = "suspend-then-hibernate";
  services.logind.suspendKey = "suspend-then-hibernate";
  services.logind.powerKey = "hibernate";

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=yes
    HibernateDelaySec=1h
    '';

  services.upower.enable = true;
  services.upower.criticalPowerAction = "Hibernate";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.plymouth.enable = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.resumeDevice = "/dev/mapper/ROOT";
  boot.kernelParams = [ "quiet" "i915.enable_psr=0" "udev.log_level=0" "resume_offset=29921280" ];
  boot.blacklistedKernelModules = [ "intel_hid" "psmouse" ];

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;

  networking.hostId = "98e54f8e";
  networking.hostName = "dell-laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Docker and Virtualization
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

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

  services.avahi = {
    enable = true;
    publish = {
        enable = true;
        addresses = true;
        workstation = true;
    };
  };

  services.keybase.enable = true;
  services.kbfs.enable = true;

  services.fwupd.enable = true;
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-broadcom;

  security.pam.services.login.fprintAuth = false;

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig.pipewire = {
      "10-airplay" = {
        "context.modules" = [
          {
            name = "libpipewire-module-raop-discover";
          }
        ];
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chris = {
    isNormalUser = true;
    description = "Chris";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "vboxusers" "dialout" ];
    shell = pkgs.zsh;
  };

  users.users.hope = {
    isNormalUser = true;
    description = "Hope";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";
  services.tailscale.extraUpFlags = [
    "--operator=chris"
    "--accept-routes"
  ];

  #services.fprintd.enable = true;
  #services.fprintd.tod.enable = true;
  #services.fprintd.tod.driver = (import ./fingerprint-broadcom.nix);

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pciutils
    inxi
    killall
    sshfs-fuse
    htop
    glances
    gnupg
    unrar
  ];

  services.flatpak.enable = true;

  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }];

  services.flatpak.update.auto.enable = false;
  services.flatpak.uninstallUnmanaged = false;

  services.flatpak.packages = [
    "app.zen_browser.zen"
    "ca.desrt.dconf-editor"
    "com.getpostman.Postman"
    "io.github.mrvladus.List"
    "md.obsidian.Obsidian"
    "org.gnome.Boxes"
    "org.gnome.Calculator"
    "org.gnome.Calendar"
    "org.gnome.Contacts"
    "org.gnome.Decibels"
    "org.gnome.Epiphany"
    "org.gnome.Geary"
    "org.gnome.World.PikaBackup"
    "org.gnome.gedit"
    "org.signal.Signal"
    "org.videolan.VLC"
    "org.virt_manager.virt-manager"
    "org.gnome.Papers"
  ];

  programs.zsh.enable = true;
  programs.steam.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
