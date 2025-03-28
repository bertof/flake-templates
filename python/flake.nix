{
  description = "A basic Python flake";

  nixConfig.extra-substituters = [ "http://nix-cache.cluster.sesar.int" ];

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [
      # To import a flake module
      # 1. Add foo to inputs
      # 2. Add foo as a parameter to the outputs function
      # 3. Add here: foo.flakeModule
      inputs.pre-commit-hooks-nix.flakeModule
    ];
    perSystem =
      { config
        # , self'
        # , inputs'
      , pkgs
        # , system
      , ...
      }:
      let
        py = pkgs.python3;
        pyPkgs = py.pkgs;
      in
      {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # # This sets `pkgs` to a nixpkgs with allowUnfree option set.
        # _module.args.pkgs = import nixpkgs {
        #   inherit system;
        #   config.allowUnfree = true;
        # };

        pre-commit.settings.hooks = {
          deadnix.enable = true;
          nixpkgs-fmt.enable = true;
          statix.enable = true;

          autoflake.enable = true;
          black.enable = true;
        };

        devShells.default = pkgs.mkShell {
          name = "impurePythonEnv";
          venvDir = ".venv";
          buildInputs = [
            py
            pyPkgs.venvShellHook

            pkgs.ruff

            # pkgs.python3Packages.ipython
            # (pkgs.python3Packages.matplotlib.override { enableTk = true; })
            # pkgs.python3Packages.pandas
            # pkgs.python3Packages.seaborn
          ];

          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            find . -name requirements.txt -exec pip install -r {} \;
          '';

          postShellHook = ''
            # allow pip to install wheels
            unset SOURCE_DATE_EPOCH
            ${config.pre-commit.installationScript}
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      };
    flake = {
      # The usual flake attributes can be defined here, including system-
      # agnostic ones like nixosModule and system-enumerating ones, although
      # those are more easily expressed in perSystem.
    };
  };
}
