{
  pkgs ? import <nixpkgs> { },
}:

{
  intellij-idea-ultimate = pkgs.callPackage ./intellij-idea-ultimate.nix { };
}
