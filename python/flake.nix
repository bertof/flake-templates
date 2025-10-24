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
    perSystem = { config, pkgs, ... }: {
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
        inputsFrom = [ config.pre-commit.devShell ];
        packages = with pkgs; [
          (python3.withPackages (p: [ p.ipython ]))
          ruff
          uv
        ];
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
