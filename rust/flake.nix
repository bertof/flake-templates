{
  description = "A basic development flake for this Rust based project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
    systems.url = "github:nix-systems/default";
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
      , system
      , lib
      , ...
      }:
      let minBuildInputs = with pkgs; [ rustc stdenv.cc ]; in {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # This sets `pkgs` to a nixpkgs with allowUnfree option set.
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.rust-overlay.overlays.default
            (self: _super: rec {
              clippy = rustc;
              rustc = self.rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "x86_64-unknown-linux-gnu" "aarch64-unknown-linux-gnu" ];
              };
              rustfmt = rustc;
            })
          ];
          # config.allowUnfree = true;
        };


        pre-commit = {
          inherit pkgs;
          settings.hooks = {
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;

            clippy.enable = true;
            rustfmt.enable = true;
            cargo-test = {
              enable = true;
              name = "cargo test";
              description = "Test Rust code.";
              entry =
                let
                  s = pkgs.writeShellScript "cargo test" ''
                    export PATH=${lib.makeBinPath minBuildInputs}
                    cargo test'';
                in
                "${s}";
              files = "\\.rs$";
              pass_filenames = false;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ rustc ];
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
