{
  description = "Chris Nix Flake";

  # This is the standard format for flake.nix.
  # `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake.
  # Each item in `inputs` will be passed as a parameter to
  # the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs.
    # The most widely used is `github:owner/name/reference`,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    zfs-multi-mount.url = "github:gbytedev/zfs-multi-mount/master";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager?ref=release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";

    walker.url = "github:abenz1267/walker";
    walker.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  # `outputs` are all the build result of the flake.
  #
  # A flake can have many use cases and different types of outputs.
  #
  # parameters in function `outputs` are defined in `inputs` and
  # can be referenced by their names. However, `self` is an exception,
  # this special parameter points to the `outputs` itself(self-reference)
  #
  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      home-manager-unstable,
      zfs-multi-mount,
      nix-flatpak,
      walker,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        # By default, NixOS will try to refer the nixosConfiguration with
        # its hostname, so the system named `nixos-test` will use this one.
        # However, the configuration name can also be specified using:
        #   sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>
        #
        # The `nixpkgs.lib.nixosSystem` function is used to build this
        # configuration, the following attribute set is its parameter.
        #
        # Run the following command in the flake's directory to
        # deploy this configuration on any NixOS system:
        #   sudo nixos-rebuild switch --flake .#nixos-test
        "dell-laptop" = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nix-flatpak.nixosModules.nix-flatpak

            # Import the configuration.nix here, so that the
            # old configuration file can still take effect.
            # Note: configuration.nix itself is also a Nixpkgs Module,
            ./systems/dell-laptop/configuration.nix

            home-manager-unstable.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.chris = import ./systems/dell-laptop/home.nix;

              # Pass inputs to home-manager
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };

        "rose-laptop" = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nix-flatpak.nixosModules.nix-flatpak

            ./systems/rose-laptop/configuration.nix

            home-manager-unstable.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.chris = import ./systems/rose-laptop/home.nix;

              # Pass inputs to home-manager
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };

        "server" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./systems/server/configuration.nix
            {
              environment.systemPackages = [ zfs-multi-mount.packages.x86_64-linux.default ];
            }

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.chris = import ./systems/server/home.nix;

              # Pass inputs to home-manager
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
      };

      darwinConfigurations."Chriss-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [ ./systems/macbook/configuration.nix ];
      };

      homeConfigurations."chris" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./homes/chris ];

        # Pass inputs to home-manager
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
