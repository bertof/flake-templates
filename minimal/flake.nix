{
  description = "Minimal flake environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = flattenTree {
          hello = pkgs.hello;
        };
        defaultPackage = self.packages.${system}.hello;
        apps = {
          hello = mkApp { drv = self.packages.${system}.hello; };
        };
        defaultApp = apps.hello;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            self.packages.${system}.hello
          ];
        };
      });
}
