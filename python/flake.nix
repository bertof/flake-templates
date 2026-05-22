{
  description = "A basic Python flake";

  inputs = {
    systems.url = "github:nix-systems/default";
    dotfiles.url = "gitlab:bertof/nix-dotfiles";
    nixpkgs.follows = "dotfiles/nixpkgs";
    flake-parts.follows = "dotfiles/flake-parts";
    git-hooks.follows = "dotfiles/git-hooks";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [
      # To import a flake module
      # 1. Add foo to inputs
      # 2. Add foo as a parameter to the outputs function
      # 3. Add here: foo.flakeModule
      inputs.git-hooks.flakeModule
    ];
    perSystem = { self', config, pkgs, ... }: {
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

      devShells = {
        default = self'.devShells.code;

        code =
          let uvPython = pkgs.python3;
          in pkgs.mkShell {
            inputsFrom = [ config.pre-commit.devShell ];
            packages = with pkgs; [
              ruff # Python LSP
              uv # Python package manager
            ];
            env = {
              UV_NO_SYNC = "1";
              UV_PYTHON = "${uvPython.interpreter}";
              UV_PYTHON_DOWNLOADS = "never";
            };
            shellHook = ''
              unset SOURCE_DATE_EPOCH
              export LD_LIBRARY_PATH="${pkgs.libgcc.lib}/lib:$LD_LIBRARY_PATH"
              export REPO_ROOT=$(git rev-parse --show-toplevel)
              unset PYTHONPATH

              export VIRTUAL_ENV="$REPO_ROOT/.venv"
              export PATH="$VIRTUAL_ENV/bin:$PATH"

              if [ ! -d "$VIRTUAL_ENV" ]; then
                uv venv --python ${uvPython.interpreter}
              fi

              uv sync --extra dev
            '';
          };
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
