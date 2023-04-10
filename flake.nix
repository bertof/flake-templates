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
    (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = builtins.path { name = "flake-templates-src"; path = ./.; };
            hooks = {
              deadnix.enable = true;
              nixpkgs-fmt.enable = true;
              statix.enable = true;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };

        formatter = pkgs.nixpkgs-fmt;
      })) // {
      templates = rec {
        default = pre-commit;
        paper = {
          path = ./paper;
          description = "Latex paper with pre-commit checks";
        };
        presentation = {
          path = ./presentation;
          description = "Latex presentation with pre-commit checks";
        };
        pre-commit = {
          path = ./pre-commit;
          description = "Basic flake environment with pre-commit checks";
        };
        python = {
          path = ./python;
          description = "Python with pre-commit checks";
        };
        rust = {
          path = ./rust;
          description = "Rust library with pre-commit checks";
        };
      };
    };
}
