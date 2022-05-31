{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    tex2nix = { url = "github:Mic92/tex2nix"; inputs.utils.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ ({ inherit (tex2nix.packages) tex2nix; }) ]; };
      texScheme = (pkgs.callPackage ./tex-env.nix {
        extraTexPackages = { inherit (pkgs.texlive) scheme-medium datatool ncctools preprint xypic; };
      });
    in
    rec {
      packages = pkgs // rec {
        default = document;

        document = pkgs.stdenvNoCC.mkDerivation rec {
          name = "main.pdf";
          src = self;
          buildInputs = [ texScheme pkgs.coreutils ];
          phases = [ "unpackPhase" "buildPhase" "installPhase" ];
          buildPhase = "${compile}/bin/compile_script main.tex";
          installPhase = "install main.pdf $out";
        };

        compile = pkgs.writeShellScriptBin "compile_script" ''
          export PATH="${pkgs.lib.makeBinPath [texScheme pkgs.coreutils]}";
          mkdir -p .cache/texmf-var
          latexmk -c
          env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
            latexmk -interaction=nonstopmode -pdf ''${@:-main.tex}
        '';

        auto_compile = pkgs.writeShellScriptBin "auto_compile_script" ''
          ${pkgs.watchexec}/bin/watchexec -e tex,bib ${packages.compile}/bin/compile_script ''${@:-main.tex}
        '';
      };

      apps = rec {
        default = auto_compile;
        compile = { type = "app"; program = "${packages.compile}/bin/compile_script"; };
        auto_compile = { type = "app"; program = "${packages.auto_compile}/bin/auto_compile_script"; };
      };

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [ texScheme watchexec tex2nix ];
        shellHook = ''
          ${self.checks.${system}.pre-commit-check.shellHook}
        '';
      };
    });
}
