with import <nixpkgs> {}; # bring all of Nixpkgs into scope
stdenv.mkDerivation {
  pname = "libfprint-2-tod1-broadcom";
  version = "0.0.1";

  src = fetchgit {
    url = "https://git.launchpad.net/~oem-solutions-engineers/libfprint-2-tod1-broadcom/+git/libfprint-2-tod1-broadcom";
    rev = "refs/heads/upstream";
    sha256 = "sha256-0C2PpYpEJNrU+8NT95w4QV0J5nHQisMY94Czw3jQOzw=";
  };

  buildPhase = ''
    patchelf \
      --set-rpath ${lib.makeLibraryPath [ libfprint-tod ]} \
      usr/lib/x86_64-linux-gnu/libfprint-2/tod-1/libfprint-2-tod-1-broadcom.so
    ldd usr/lib/x86_64-linux-gnu/libfprint-2/tod-1/libfprint-2-tod-1-broadcom.so
  '';

  installPhase = ''
    mkdir -p "$out/usr/lib/libfprint-2/tod-1/"
    mkdir -p "$out/usr/lib/udev/rules.d/"
    mkdir -p "$out/var/lib/fprint/fw/"
    cp usr/lib/x86_64-linux-gnu/libfprint-2/tod-1/libfprint-2-tod-1-broadcom.so "$out/usr/lib/libfprint-2/tod-1/"
    cp lib/udev/rules.d/60-libfprint-2-device-broadcom.rules "$out/usr/lib/udev/rules.d/"
    cp var/lib/fprint/fw/* "$out/var/lib/fprint/fw/"
  '';

  passthru.driverPath = "/lib/libfprint-2/tod-1";

  meta = with lib; {
    description = "Broadcom driver module for libfprint-2-tod Touch OEM Driver";
    homepage = "https://git.launchpad.net/~oem-solutions-engineers/libfprint-2-tod1-broadcom/+git/libfprint-2-tod1-broadcom/";
    platforms = platforms.linux;
  };
}
