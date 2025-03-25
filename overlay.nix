self: super: {
  libfprint-tod = super.libfprint-tod.overrideAttrs (oldAttrs: rec {
    version = "1.94.9+tod1";

    src = super.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "3v1n0";
      repo = "libfprint";
      rev = "v${version}";
      sha256 = "xkywuFbt8EFJOlIsSN2hhZfMUhywdgJ/uT17uiO3YV4=";
    };

    mesonFlags = [
      "-Ddrivers=all" # Enable all virtual drivers for `fprintd` tests
      "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
      "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
    ];

    postPatch = ''
      ${oldAttrs.postPatch or ""} # Ensure `postPatch` doesn't break overriding
      patchShebangs \
        ./libfprint/tod/tests/*.sh \
        ./tests/*.py \
        ./tests/*.sh
    '';
  });
}