{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    tex2nix = { url = "github:Mic92/tex2nix"; inputs.utils.follows = "nixpkgs"; };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, tex2nix, pre-commit-hooks }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ (_: _: { inherit (tex2nix.packages) tex2nix; }) ]; };
      texScheme = pkgs.texlive.combined.scheme-full;
      # texScheme = (pkgs.callPackage ./tex-env.nix {
      #   extraTexPackages = {
      #     inherit (pkgs.texlive) scheme-medium
      #       algorithms
      #       caption
      #       datatool
      #       glossaries
      #       ieeetran
      #       mfirstuc
      #       preprint
      #       xfor
      #       xypic
      #       ;
      #   };
      # });
    in
    rec {
      packages = rec {
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

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              nix-linter.enable = true;
            };
          };
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
      };
    });
}    
