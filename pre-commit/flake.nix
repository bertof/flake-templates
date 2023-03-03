{
  description = "Minimal flake environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = builtins.path {
              path = ./.;
              name = "flake-templates-src";
            };
            hooks = {
              deadnix.enable = true;
              nixpkgs-fmt.enable = true;
              statix.enable = true;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${self.checks.${system}.pre-commit-check.shellHook}
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
