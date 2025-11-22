{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../homes/chris/common.nix
  ];

  home.sessionVariables."EDITOR" = lib.mkForce "nano"; # Don't judge me!
}
