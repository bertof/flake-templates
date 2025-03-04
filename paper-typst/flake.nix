{
  description = "Minimal flake environment";

  nixConfig.extra-substituters = [ "http://nix-cache.cluster.sesar.int" ];

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [
      inputs.pre-commit-hooks-nix.flakeModule
    ];
    perSystem = { config, pkgs, ... }: {
      pre-commit.settings.hooks = {
        deadnix.enable = true;
        nixpkgs-fmt.enable = true;
        statix.enable = true;

        typstyle = {
          enable = true;
          name = "typstyle";
          entry = "${pkgs.typstyle}/bin/typstyle format-all";
          files = "*.typ";
          pass_filenames = false;
        };
      };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [ tinymist typst typstyle ];
        shellHook = ''
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
