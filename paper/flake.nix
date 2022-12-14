{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    tex2nix.url = "github:Mic92/tex2nix";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, tex2nix, pre-commit-hooks }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ (_: _: { inherit (tex2nix.packages.${system}) tex2nix; }) ]; };
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

      compile = pkgs.writeShellScript "compile_script" ''
        export PATH="${pkgs.lib.makeBinPath [texScheme pkgs.coreutils]}";
        mkdir -p .cache/texmf-var
        latexmk -c
        env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
          latexmk -interaction=nonstopmode -pdf ''${@:-main.tex}
      '';

      fast_compile = pkgs.writeShellScript "compile_script" ''
        export PATH="${pkgs.lib.makeBinPath [texScheme pkgs.coreutils]}";
        mkdir -p .cache/texmf-var
        env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
          latexmk -interaction=nonstopmode -pdf ''${@:-main.tex}
      '';

      auto_compile = pkgs.writeShellScript "auto_compile_script" ''
        ${pkgs.watchexec}/bin/watchexec -e tex,bib ${compile} ''${@:-main.tex}
      '';

      fast_auto_compile = pkgs.writeShellScript "auto_compile_script" ''
        ${pkgs.watchexec}/bin/watchexec -e tex,bib ${fast_compile} ''${@:-main.tex}
      '';

      clean_bibliography = pkgs.writeShellScript "clean_bibliography" ''
        ${pkgs.bibclean}/bin/bibclean \
          -align-equals \
          -brace-protect \
          -check-values \
          -fix-accents \
          -fix-initials \
          -fix-names \
          -output-file biblio.bib <(cat biblio.bib) 
      '';
    in
    rec {
      packages = rec {
        default = document;

        document = pkgs.stdenvNoCC.mkDerivation rec {
          name = "main.pdf";
          src = self;
          buildInputs = [ texScheme pkgs.coreutils ];
          phases = [ "unpackPhase" "buildPhase" "installPhase" ];
          buildPhase = "${compile} main.tex";
          installPhase = "install main.pdf $out";
        };
      };

      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            nix-linter.enable = true;
          };
        };
      };

      apps = {
        default = { type = "app"; program = "${auto_compile}"; };
        compile = { type = "app"; program = "${compile}"; };
        fast_compile = { type = "app"; program = "${fast_compile}"; };
        auto_compile = { type = "app"; program = "${auto_compile}"; };
        fast_auto_compile = { type = "app"; program = "${fast_auto_compile}"; };
        clean_bibliography = { type = "app"; program = "${clean_bibliography}"; };
      };

      devShells.default = pkgs.mkShell {
        buildInputs = [ texScheme pkgs.watchexec pkgs.tex2nix ];
        shellHook = ''
          ${self.checks.${system}.pre-commit-check.shellHook}
        '';
      };
    }
  );
}    
