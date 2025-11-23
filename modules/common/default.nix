{
  # Import all common modules for a typical desktop/laptop system
  imports = [
    ./locale.nix
    ./nix.nix
    ./networking.nix
    ./hardware.nix
    ./packages.nix
    ./shell.nix
    ./flatpak.nix
    ./virtualization.nix
    ./appimage.nix
    ./development.nix
  ];
}
