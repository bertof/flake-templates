{
  description = "A collection of project templates";

  inputs = {
    systems.url = "github:nix-systems/default";
    dotfiles.url = "gitlab:bertof/nix-dotfiles";
    nixpkgs.follows = "dotfiles/nixpkgs";
    flake-parts.follows = "dotfiles/flake-parts";
    git-hooks.follows = "dotfiles/git-hooks";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [ inputs.git-hooks.flakeModule ];
    perSystem = { config, pkgs, ... }: {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          ${config.pre-commit.installationScript}
        '';
      };
      pre-commit = {
        inherit pkgs;
        settings = {
          hooks = {
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        };
      };
      formatter = pkgs.nixpkgs-fmt;
    };
    flake = {
      templates = rec {
        default = basic;
        paper = { path = ./paper; description = "Latex paper with pre-commit checks"; };
        paper-typst = { path = ./paper-typst; description = "IEEE paper based on typst with pre-commit checks"; };
        presentation = { path = ./presentation; description = "Latex presentation with pre-commit checks"; };
        latex = { path = ./latex; description = "Latex with pre-commit checks"; };
        thesis = { path = ./thesis; description = "Latex thesis with pre-commit checks"; };
        basic = { path = ./basic; description = "Basic flake environment with pre-commit checks"; };
        python = { path = ./python; description = "Python with pre-commit checks"; };
        rust = { path = ./rust; description = "Rust library with pre-commit checks"; };
      };
    };
  };
}
