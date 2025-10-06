# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./filesystems.nix
    # ../../desktops/gnome.nix # Include the GNOME Desktop Environment.
    #../../desktops/plasma.nix # Include the Plasma Desktop Environment.
    # ../../desktops/hyprland.nix # Include the Hyprland Window Manager.
    ../../desktops/niri.nix # Include the Niri Window Manager.
  ];

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Walker binary cache for faster builds
    settings.substituters = [
      "https://cache.nixos.org/"
      "https://walker.cachix.org"
    ];
    settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
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

  # required for hibernation
  security.protectKernelImage = false;

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleSuspendKey = "suspend-then-hibernate";
  services.logind.settings.Login.HandlePowerKey = "hibernate";

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
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [
    "quiet"
    "i915.enable_psr=0"
    "udev.log_level=0"
    "resume_offset=12376136"
  ];
  boot.blacklistedKernelModules = [
    "intel_hid"
    "psmouse"
  ];

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
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
      "vboxusers"
      "dialout"
    ];
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
    msedit
    pciutils
    inxi
    killall
    sshfs-fuse
    htop
    glances
    gnupg
    unrar
    unzip
  ];

  services.flatpak.enable = true;

  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  services.flatpak.update.auto.enable = true;
  services.flatpak.uninstallUnmanaged = true;

  services.flatpak.packages = [
    "app.zen_browser.zen"
    "com.getpostman.Postman"
    "md.obsidian.Obsidian"
    "org.gnome.Boxes"
    "org.gnome.Calendar"
    "org.gnome.Contacts"
    "org.gnome.Geary"
    "io.github.mrvladus.List"
    "org.gnome.gedit"
    "org.signal.Signal"
    "org.videolan.VLC"
    "org.gnome.Papers"
    "org.gnome.Loupe"
    "org.virt_manager.virt-manager"
  ];

  services.flatpak.overrides = {
    global = {
      # Force Wayland by default
      Context.sockets = [
        "wayland"
        "!x11"
        "!fallback-x11"
      ];

      Environment = {
        # Force correct theme for some GTK apps
        GTK_THEME = "Adwaita:dark";
      };
    };
  };

  programs.zsh.enable = true;
  programs.steam.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [

    # Checked in studio.sh
    coreutils
    findutils
    gnugrep
    which
    gnused

    # For Android emulator
    file
    mesa-demos
    pciutils
    xorg.setxkbmap

    # Used during setup wizard
    gnutar
    gzip

    # Runtime stuff
    git
    ps
    usbutils

    # Crash at startup without these
    fontconfig
    freetype
    libxext
    xorg.libXi
    libxrender
    xorg.libXtst

    # No crash, but attempted to load at startup
    e2fsprogs

    # Gradle wants libstdc++.so.6
    (lib.getLib stdenv.cc.cc)
    # mksdcard wants 32 bit libstdc++.so.6
    pkgsi686Linux.stdenv.cc.cc.lib

    # aapt wants libz.so.1
    zlib
    pkgsi686Linux.zlib
    # Support multiple monitors
    libxrandr

    # For Android emulator
    alsa-lib
    dbus
    expat
    libbsd
    libpulseaudio
    libuuid
    libx11
    libxcb
    libxkbcommon
    libxcb-wm
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    xcb-util-cursor
    xorg.libICE
    xorg.libSM
    xorg.libxkbfile
    xorg.libXcomposite
    libxcursor
    xorg.libXdamage
    libxfixes
    libGL
    libdrm
    libpng
    nspr
    nss_latest
    systemd

    # For GTKLookAndFeel
    gtk2
    glib

    # For wayland support
    wayland
  ];

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
