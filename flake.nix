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

  outputs = { nixpkgs, flake-utils, pre-commit-hooks, ... }: with flake-utils.lib;
    rec {
      defaultTemplate = templates.pre-commit;
      templates = {
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
      };
    }
    // (eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; }; in
      rec {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              nix-linter.enable = true;
            };
          };
        };
        devShell = pkgs.mkShell {
          inherit (checks.pre-commit-check) shellHook;
        };
      }));
}
