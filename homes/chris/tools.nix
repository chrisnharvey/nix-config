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
  # Headless-safe CLI/dev tooling shared across every NixOS machine.
  # GUI apps (e.g. ghostty) belong in the individual machine configs.
  # The Darwin machine installs the equivalents via Homebrew, see
  # systems/macbook/configuration.nix.
  home.packages = with pkgs; [
    (pkgs.herdr or unstable.herdr)
    claude-code
    fresh-editor
    lazygit
    lazysql
    lego
    opentofu
  ];
}
