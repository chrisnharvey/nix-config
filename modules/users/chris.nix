{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Define chris user account
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
      "scanner"
      "lp"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgZSwNSFRZk2XJBT6PXdeQdYJEUAYdhYZCtfcPwPtLt"
    ];
  };

  # Enable ecryptfs for user encryption
  security.pam.enableEcryptfs = lib.mkDefault true;
}
