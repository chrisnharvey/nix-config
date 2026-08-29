{
  inputs,
  pkgs,
  ...
}:
let
  # The server tracks nixpkgs 26.05, which predates some of these packages.
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # CLI/dev tooling shared across the NixOS machines.
  # The Darwin machine installs the equivalents via Homebrew, see
  # systems/macbook/configuration.nix.
  home.packages = with pkgs; [
    (pkgs.herdr or unstable.herdr)
    claude-code
    fresh-editor
    lazygit
    lazysql
    ghostty
    lego
    opentofu
  ];
}
