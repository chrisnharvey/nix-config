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
  };

  # Enable ecryptfs for user encryption
  security.pam.enableEcryptfs = lib.mkDefault true;
}
