{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      # texScheme = pkgs.texlive.combined.scheme-full; # Full texlive distribution

      # Individual packages
      texScheme = pkgs.texlive.combine {
        inherit (pkgs.texlive)
          scheme-medium
          algorithms
          arydshln
          caption
          datatool
          glossaries
          ieeetran
          makecell
          mfirstuc
          multirow
          preprint
          soul
          subfigure
          xfor
          xypic;
      };
    in
    rec {
      packages = {
        default = document;

        document = pkgs.stdenvNoCC.mkDerivation rec {
          name = "main.pdf";
          src = ./.;
          buildInputs = [ texScheme pkgs.coreutils ];
          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
              latexmk -interaction=nonstopmode -pdf -pdflatex \
              main.tex
          '';
          installPhase = ''
            install main.pdf $out
          '';
        };

        compile = pkgs.writeShellScriptBin "compile_script" ''
          export PATH="${pkgs.lib.makeBinPath [texScheme pkgs.coreutils]}";
          mkdir -p .cache/texmf-var
          env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
            latexmk -interaction=nonstopmode -pdf $@
        '';

        auto_compile = pkgs.writeShellScriptBin "auto_compile_script" ''
          ${pkgs.watchexec}/bin/watchexec -e tex,bib ${packages.compile}/bin/compile_script $@
        '';
      };

      apps = rec {
        default = auto_compile;
        compile = { type = "app"; program = "${packages.compile}/bin/compile_script"; };
        auto_compile = { type = "app"; program = "${packages.auto_compile}/bin/auto_compile_script"; };
      };

      devShells.default = pkgs.mkShell { buildInputs = with pkgs; [ texScheme watchexec ]; };
    });
}
