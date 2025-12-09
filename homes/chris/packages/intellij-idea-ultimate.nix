{
  pkgs,
  lib,
  stdenv,
  fetchurl,
  ...
}:

let
  version = "2025.3";

  # Architecture-specific configuration
  sources = {
    x86_64-linux = {
      url = "https://download.jetbrains.com/idea/ideaIU-${version}.tar.gz";
      sha256 = "E/QXS6FsHO8EhxyyYUM1NtACWGwmmoCTksIO4/lJWfU=";
    };
    aarch64-linux = {
      url = "https://download.jetbrains.com/idea/ideaIU-${version}-aarch64.tar.gz";
      sha256 = "B8g6nSGfqJRbasy38yhGWFU+XIEgU6l2Ibj4S8Ax5Xw=";
    };
  };

  platform = stdenv.hostPlatform.system;
  source = sources.${platform} or (throw "Unsupported platform: ${platform}");
in
stdenv.mkDerivation rec {
  pname = "intellij-idea-ultimate";
  inherit version;

  src = fetchurl {
    url = source.url;
    sha256 = source.sha256;
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    wrapGAppsHook3
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libpam_misc.so.0"
    "libpam.so.0"
    "libaudit.so.1"
    "liblldb.so"
  ];

  buildInputs = with pkgs; [
    # Basic runtime dependencies
    stdenv.cc.cc.lib
    fontconfig
    freetype
    xorg.libX11
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.libXtst
    xorg.libXxf86vm
    libGL
    glib
    gtk3
    zlib

    # Android development dependencies (from shell.nix)
    coreutils
    findutils
    gnugrep
    which
    gnused
    file
    mesa-demos
    pciutils
    xorg.setxkbmap
    gnutar
    gzip
    git
    ps
    usbutils
    e2fsprogs
    libxrandr
    alsa-lib
    dbus
    expat
    libbsd
    libpulseaudio
    libuuid
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
    libdrm
    libpng
    nspr
    nss_latest
    systemd
    gtk2
    wayland
    # Additional libraries that might be needed (but will be ignored if missing)
    pam
    linux-pam
    lldb
  ];

  installPhase = ''
        runHook preInstall
        
        mkdir -p $out
        cp -r . $out/
        
        # Create bin directory and wrapper script
        mkdir -p $out/bin
        
        cat > $out/bin/idea-ultimate << EOF
    #!/bin/sh
    # Set up library path for Android development
    export LD_LIBRARY_PATH="${lib.makeLibraryPath buildInputs}:\$LD_LIBRARY_PATH"
    exec $out/bin/idea.sh "\$@"
    EOF
        
        chmod +x $out/bin/idea-ultimate
        
        # Create desktop entry
        mkdir -p $out/share/applications
        cat > $out/share/applications/intellij-idea-ultimate.desktop << EOF
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=IntelliJ IDEA Ultimate
    Icon=$out/bin/idea.svg
    Exec=$out/bin/idea-ultimate %f
    Comment=Capable and Ergonomic IDE for JVM
    Categories=Development;IDE;
    Terminal=false
    StartupWMClass=jetbrains-idea
    StartupNotify=true
    MimeType=text/x-java;text/x-scala;text/x-kotlin;
    EOF
        
        runHook postInstall
  '';

  meta = with lib; {
    description = "Capable and Ergonomic IDE for JVM";
    longDescription = ''
      IntelliJ IDEA Ultimate is a Java integrated development environment (IDE) 
      for developing computer software. It is developed by JetBrains and is 
      available as an Apache 2 Licensed community edition, and in a proprietary 
      commercial edition.
    '';
    homepage = "https://www.jetbrains.com/idea/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
