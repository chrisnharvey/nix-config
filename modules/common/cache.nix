{ config, pkgs, ... }:

{
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://walker.cachix.org"
    "https://nixos-apple-silicon.cachix.org"
    "https://chrisnharvey.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
    "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    "chrisnharvey.cachix.org-1:w7UXl6k2s/gFNs/Ai/dTzGo22aNHKAwJMYHkgpxSqHo="
  ];
}
