{ config, lib, pkgs, ... }:
{
  # Docker support
  virtualisation.docker.enable = lib.mkDefault true;
  
  # Libvirt/KVM support
  virtualisation.libvirtd.enable = lib.mkDefault true;
}
