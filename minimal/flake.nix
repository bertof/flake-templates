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
      rec
      {
        packages = flattenTree rec {
          default = hello;
          hello = pkgs.hello;
        };
        apps = rec {
          default = hello;
          hello = mkApp { drv = packages.hello; };
        };
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            self.packages.${system}.hello
          ];
        };
      });
}
