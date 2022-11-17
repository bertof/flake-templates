{
  description = "A collection of project templates";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks, ... }: with flake-utils.lib;
    rec {
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
    }
    // (eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; }; in
      {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              nix-linter.enable = true;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      }));
}
