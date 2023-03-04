{
  description = "A basic development flake for this Rust based project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, pre-commit-hooks }:
    let
      extensions = [ "rust-src" ];
      targets = [ "x86_64-unknown-linux-gnu" "aarch64-unknown-linux-gnu" ];
      overlays = [ rust-overlay.overlays.default ];
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
        rustc = pkgs.rust-bin.stable.latest.default.override { inherit extensions targets; };
        minBuildInputs = [ rustc pkgs.cargo pkgs.stdenv.cc ];
      in
      with nixpkgs.lib; {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = builtins.path { name = "flake-templates-src"; path = ./.; };

            tools = {
              rustfmt = rustc;
              clippy = rustc;
            };

            hooks = {
              clippy.enable = true;
              rustfmt.enable = true;
              cargo-test = {
                enable = true;
                name = "cargo test";
                description = "Test Rust code.";
                entry =
                  let
                    s = pkgs.writeShellScript "cargo test" ''
                      export PATH=${makeBinPath minBuildInputs}
                      cargo test'';
                  in
                  "${s}";
                files = "\\.rs$";
                pass_filenames = false;
              };
              deadnix.enable = true;
              nixpkgs-fmt.enable = true;
              statix.enable = true;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = minBuildInputs;
          shellHook = "${self.checks.${system}.pre-commit-check.shellHook}";
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
