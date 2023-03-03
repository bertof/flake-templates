{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        myPython = pkgs.python3;
        myPackages = myPython.pkgs;
      in
      {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = builtins.path { path = ./.; name = "flake-templates-src"; };
            hooks = {
              deadnix.enable = true;
              nixpkgs-fmt.enable = true;
              statix.enable = true;

              autoflake.enable = true;
              black.enable = true;
            };
          };
        };

        devShell = pkgs.mkShell {
          name = "impurePythonEnv";
          venvDir = ".venv";
          buildInputs = [
            myPython
            myPackages.venvShellHook

            myPackages.virtualenv
            myPackages.ipython
            (myPackages.matplotlib.override { enableTk = true; })
            myPackages.pandas
            myPackages.seaborn
          ];

          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            pip install -r requirements.txt
          '';

          postShellHook = ''
            # allow pip to install wheels
            unset SOURCE_DATE_EPOCH
            ${self.checks.${system}.pre-commit-check.shellHook}
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
