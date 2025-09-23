# filepath: flake.nix
{
  description = "Dev env for MA";

  nixConfig = {
    extra-substituters = [
      "https://rstats-on-nix.cachix.org"
      "https://rde.cachix.org"
    ];
    extra-trusted-public-keys = [
      "rstats-on-nix.cachix.org-1:vdiiVgocg6WeJrODIqdprZRUrhi1JzhBnXv7aWI6+F0="
      "rde.cachix.org-1:yRxQYM+69N/dVER6HNWRjsjytZnJVXLS/+t/LI9d1D4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:rstats-on-nix/nixpkgs/2025-09-01";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    allSystems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    forAllSystems = f:
      nixpkgs.lib.genAttrs allSystems (
        system:
          f {
            # Use legacyPackages instead of importing the flake path manually
            pkgs = nixpkgs.legacyPackages.${system};
          }
      );
  in {
    packages = forAllSystems ({pkgs}: {
      default = pkgs.rWrapper.override {
        packages =
          # External R packages list (expects r-packages.nix to return a list)
          import ./r-packages.nix {inherit pkgs;};
      };
    });
    devShells = forAllSystems ({pkgs}: {
      default = pkgs.mkShell {
        packages = [
          (pkgs.rWrapper.override {
            packages =
              # External R packages list (expects r-packages.nix to return a list)
              import ./r-packages.nix {inherit pkgs;};
          })
        ];
      };
    });
  };
}
