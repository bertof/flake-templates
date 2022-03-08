{
  description = "Minimal flake environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, flake-utils }:
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
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            hello
          ];
        };
      });
}
