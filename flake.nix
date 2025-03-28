{
  description = "Chris NixOS Flake";

  # This is the standard format for flake.nix.
  # `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake.
  # Each item in `inputs` will be passed as a parameter to
  # the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs.
    # The most widely used is `github:owner/name/reference`,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager?ref=release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
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
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, home-manager-unstable, ... }@inputs: {
    overlays.default = import ./overlay.nix;

    packages.x86_64-linux = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };
    in {
      libfprint-tod = pkgs.libfprint-tod;
    };

    nixosModules.default = { config, pkgs, ... }: {
      nixpkgs.overlays = [ self.overlays.default ];
    };

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
          # Import the configuration.nix here, so that the
          # old configuration file can still take effect.
          # Note: configuration.nix itself is also a Nixpkgs Module,
          ./systems/dell-laptop/configuration.nix

          home-manager-unstable.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.chris = import ./systems/dell-laptop/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }

          # Apply the overlay within the NixOS configuration
          self.nixosModules.default 
        ];
      };

      "rose-laptop" = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./systems/rose-laptop/configuration.nix
        ];
      };

      "server" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./systems/server/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.chris = import ./systems/server/home.nix;
          }
        ];
      };
    };


    homeConfigurations."chris" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [ ./homes/chris ];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };
  };
}
