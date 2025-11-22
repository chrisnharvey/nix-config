{ config, lib, pkgs, ... }:
{
  # Android development support
  programs.appimage.enable = lib.mkDefault true;
  programs.appimage.binfmt = lib.mkDefault true;
  
  programs.nix-ld.enable = lib.mkDefault true;
  programs.nix-ld.libraries = with pkgs; lib.mkDefault [
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
}
