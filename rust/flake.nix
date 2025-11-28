{
  description = "A basic development flake for this Rust based project";

  inputs = {
    systems.url = "github:nix-systems/default";
    dotfiles.url = "gitlab:bertof/nix-dotfiles";
    nixpkgs.follows = "dotfiles/nixpkgs";
    flake-parts.follows = "dotfiles/flake-parts";
    git-hooks.follows = "dotfiles/git-hooks";

    naersk.url = "github:nix-community/naersk/master";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ flake-parts, systems, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import systems;
    imports = [
      # To import a flake module
      # 1. Add foo to inputs
      # 2. Add foo as a parameter to the outputs function
      # 3. Add here: foo.flakeModule
      inputs.git-hooks.flakeModule
    ];
    perSystem = { config, self', pkgs, lib, ... }:
      let
        naersk-lib = pkgs.callPackage inputs.naersk { };

        buildInputs = [ pkgs.pkg-config pkgs.stdenv.cc pkgs.cargo pkgs.rustc ];
        testInputs = buildInputs ++ [ pkgs.clippy pkgs.rustfmt pkgs.cargo-hack ];
        devInputs = [ pkgs.cargo-bump pkgs.cargo-semver-checks pkgs.cargo-watch pkgs.lldb pkgs.rust-analyzer ];
      in
      {
        # # This sets `pkgs` to a nixpkgs with allowUnfree option set.
        # _module.args.pkgs = import inputs.nixpkgs {
        #   inherit system;
        #   overlays = [ ];
        #   # config.allowUnfree = true;
        # };

        packages = {
          main-application = naersk-lib.buildPackage {
            pname = "main-application";
            src = ./.;
            nativeBuildInputs = with pkgs; [ pkg-config ];
          };

          main-application-docker-image = let p = self'.packages.main-application; in pkgs.dockerTools.buildImage {
            name = "main-application";
            tag = "latest";
            created = "now";
            config = {
              Cmd = [ "${p}/bin/${p.pname}" ];
              Env = [ "PATH=${lib.makeBinPath [p]}" ];
              ExposedPorts = { "3000/tcp" = { }; };
            };
          };
        };

        pre-commit = {
          inherit pkgs;
          settings = {
            hooks = {
              deadnix = { enable = true; excludes = [ "Cargo.nix" ]; };
              nixpkgs-fmt = { enable = true; excludes = [ "Cargo.nix" ]; };
              # statix = { enable = true; excludes = [ "Cargo.nix" ]; };

              clippy.enable = true;
              rustfmt.enable = true;
              cargo-check.enable = true;
              cargo-test = {
                enable = true;
                name = "cargo test";
                description = "Test Rust code.";
                entry = toString (pkgs.writeShellScript "cargo-test-hook" ''
                  export PATH=${lib.makeBinPath buildInputs}
                  cargo test
                '');
                files = "\\.rs$";
                pass_filenames = false;
              };
              cargo-semver-checks = {
                enable = true;
                name = "cargo semver-checks";
                description = "Test Rust semver info.";
                entry = toString (pkgs.writeShellScript "cargo-semver-checks-hook" ''
                  export PATH=${lib.makeBinPath (buildInputs ++ [pkgs.cargo-semver-checks])}
                  cargo semver-checks --baseline-rev main
                '');
                files = "\\.(toml)$";
                pass_filenames = false;
              };

              ci-lint = {
                enable = true;
                name = "ci lint";
                entry = "${pkgs.glab}/bin/glab ci lint";
                files = "\\.gitlab-ci.yml";
                pass_filenames = false;
              };
            };
          };
        };

        devShells = {
          default = self'.devShells.dev;

          base = pkgs.mkShell {
            inputsFrom = [ config.pre-commit.devShell ];
            packages = [ pkgs.pkg-config pkgs.stdenv.cc pkgs.cargo pkgs.rustc ];
            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
          };

          dev = pkgs.mkShell {
            inputsFrom = [ self'.devShells.base ];
            packages = testInputs ++ devInputs;
            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
          };

          tests = pkgs.mkShell {
            inputsFrom = [ self'.devShells.base ];
            packages = testInputs;
            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
          };

          podman = pkgs.mkShell { packages = [ pkgs.podman ]; };
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
