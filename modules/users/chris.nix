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

  security.pam.mount.enable = true;

  users.users.chris.pamMount = {
    fstype = "fuse";
    options = "nodev,nosuid,quiet,nonempty";
    mountpoint = "/home/%(USER)";
    path = "${pkgs.gocryptfs}/bin/gocryptfs#/home/%(USER).crypt";
    user = "chris";
    noroot="0";
  };
}
