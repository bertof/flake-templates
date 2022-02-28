{
  description = "Minimal flake environment";

  inputs = {
    nixpkgs = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
      with flake-utils.lib;
      eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in
      rec {
        packages = flattenTree {
          hello = pkgs.hello;
        };
        defaultPackage = packages.hello;
        apps = {
          hello = mkApp { drv = packages.hello; };
        };
        defaultApp = apps.hello;
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
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = with pkgs; [
            hello
          ];
        };
      });
}
