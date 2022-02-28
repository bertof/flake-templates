{
  description = "A collection of project templates";

  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks, ... }: flake-utils.lib.eachDefaultSystem (system: {

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

    checks = {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixpkgs-fmt.enable = true;
          nix-linter.enable = true;
        };
      };
    };
  });
}
