{
  description = "A collection of project templates";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks, ... }:
    {
      templates = rec {
        default = pre-commit;
        meta = {
          path = ./meta;
          description = "Common metadata files for flake based projects";
        };
        minimal = {
          path = ./minimal;
          description = "Minimal flake environment";
        };
        pre-commit = {
          path = ./pre-commit;
          description = "Basic flake environment with pre-commit checks";
        };
        paper = {
          path = ./paper;
          description = "Latex paper with pre-commit checks";
        };
        rust = {
          path = ./rust;
          description = "Rust library with pre-ocommit checks";
        };
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              deadnix.enable = true;
              nix-linter.enable = true;
              nixfmt.enable = true;
              statix.enable = true;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };

        formatter = pkgs.writeShellScriptBin "formatter" ''
          ${pkgs.findutils}/bin/find . -name '*.nix' -exec ${pkgs.nixfmt}/bin/nixfmt {} \+
        '';
      }));
}
