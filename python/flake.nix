{
  description = "A basic Python flake";

  inputs = {
    systems.url = "github:nix-systems/default";
    dotfiles.url = "gitlab:bertof/nix-dotfiles";
    nixpkgs.follows = "dotfiles/nixpkgs";
    flake-parts.follows = "dotfiles/flake-parts";
    git-hooks.follows = "dotfiles/git-hooks";
    rbw-env = {
      url = "github:bertof/rbw-env";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [
      # To import a flake module
      # 1. Add foo to inputs
      # 2. Add foo as a parameter to the outputs function
      # 3. Add here: foo.flakeModule
      inputs.git-hooks.flakeModule
      inputs.rbw-env.flakeModule
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

      pre-commit = {
        inherit pkgs;
        settings = {
          package = pkgs.prek;
          hooks = {
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;

            autoflake.enable = true;
            black.enable = true;
          };
        };
      };

      devShells = {
        default = self'.devShells.code;

        code =
          let uvPython = pkgs.python3;
          in pkgs.mkShell {
            inputsFrom = [ config.pre-commit.devShell config.rbwEnv.devShell ];
            packages = with pkgs; [
              ruff # Python LSP
              uv # Python package manager
            ];
            shellHook = ''
              # Pin uv to the nix-provided interpreter and forbid it from
              # downloading one of its own: the Python toolchain must come
              # from nix alone, or the venv would not match the shell's
              # shared libraries (LD_LIBRARY_PATH below).
              export UV_PYTHON="${uvPython.interpreter}"
              export UV_PYTHON_DOWNLOADS=never
              # The hook syncs the venv once per shell entry; stop `uv run`
              # from implicitly re-syncing (and possibly modifying the venv)
              # on every invocation.
              export UV_NO_SYNC=1

              # stdenv pins SOURCE_DATE_EPOCH to 1970 in dev shells; unset it
              # so tools that compare file timestamps behave on real time.
              unset SOURCE_DATE_EPOCH
              # Native wheels from PyPI expect libgcc in the default loader
              # path: expose nix's runtime so their shared libraries resolve
              # against the same toolchain as the interpreter.
              export LD_LIBRARY_PATH="${pkgs.libgcc.lib}/lib:$LD_LIBRARY_PATH"
              # Import resolution and the venv must be independent of the
              # current directory: drop nix's PYTHONPATH pollution, anchor
              # the venv in the project root and let tools (LSP, ruff) find
              # it through VIRTUAL_ENV without activation.
              unset PYTHONPATH
              export REPO_ROOT="$(git rev-parse --show-toplevel)"
              export VIRTUAL_ENV="$REPO_ROOT/.venv"
              export PATH="$VIRTUAL_ENV/bin:$PATH"

              # Create and sync the venv with the pinned interpreter and the
              # dev extras on first entry.
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
