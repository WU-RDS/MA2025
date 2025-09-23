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
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }
      );
  in {
    packages = forAllSystems ({
      pkgs,
      system,
    }: {
      default = pkgs.rWrapper.override {
        packages =
          import ./r-packages.nix {inherit pkgs;};
      };
      update-r = pkgs.writeShellScriptBin "update-r" ''
        #!${pkgs.bash}/bin/bash
        set -euo pipefail

        RVER=$( ${pkgs.wget}/bin/wget -qO- 'https://raw.githubusercontent.com/ropensci/rix/refs/heads/main/inst/extdata/available_df.csv' | tail -n 1 | head -n 1 | cut -d',' -f4 | tr -d '"' ) &&\
        sed -i  "s|nixpkgs.url = \"github:rstats-on-nix/nixpkgs/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\";|nixpkgs.url = \"github:rstats-on-nix/nixpkgs/$RVER\";|" flake.nix
        echo "CRAN date is $RVER"
      '';
    });

    devShells = forAllSystems ({
      pkgs,
      system,
    }: {
      default = pkgs.mkShell {
        buildInputs = [pkgs.pandoc];
        packages = [
          self.packages.${system}.update-r
          (pkgs.rWrapper.override {
            packages =
              import ./r-packages.nix {inherit pkgs;};
          })
        ];
      };
    });
  };
}
