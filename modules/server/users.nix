{ config, lib, pkgs, ... }:
{
  # User configuration for server
  users.users.chris = lib.mkDefault {
    isNormalUser = true;
    description = "Chris";
    extraGroups = [
      "networkmanager"
      "docker"
      "wheel"
      "libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgZSwNSFRZk2XJBT6PXdeQdYJEUAYdhYZCtfcPwPtLt chris@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAcJtjf0vG9Morw29uV4h7y+lnIjxQqzkTonvNncXld6 chris@steamdeck"
    ];
    packages = with pkgs; [ ];
  };

  # virt user for virtualization management
  users.groups.virt = { };
  users.users.virt = lib.mkDefault {
    isSystemUser = true;
    useDefaultShell = true;
    group = "virt";
    extraGroups = [ "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIId9wLxRIEy+It8TS6NlLpu/Bg0ug7JivClWZusQUF4x root@adde2bbe3d25"
    ];
    packages = with pkgs; [ ];
  };
}
