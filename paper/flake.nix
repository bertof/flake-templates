{
  description = "Paper flake template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        texScheme = pkgs.texlive.combined.scheme-full;
        # Using tex2nix
        # texScheme = pkgs.callPackage ./tex-env.nix {
        #   extraTexPackages = { inherit (pkgs.texlive) scheme-medium elsarticle; };
        # };

        compile = pkgs.writeShellScript "compile_script" ''
          export PATH="${pkgs.lib.makeBinPath [ texScheme pkgs.coreutils ]}";
          mkdir -p .cache/texmf-var
          latexmk -c
          env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
            latexmk -interaction=nonstopmode -pdf ''${@:-main.tex}
        '';

        compile_fast = pkgs.writeShellScript "compile_script" ''
          export PATH="${pkgs.lib.makeBinPath [ texScheme pkgs.coreutils ]}";
          mkdir -p .cache/texmf-var
          env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
            latexmk -interaction=nonstopmode -pdf ''${@:-main.tex}
        '';

        compile_auto = pkgs.writeShellScript "auto_compile_script" ''
          ${pkgs.watchexec}/bin/watchexec -e tex,bib ${compile} ''${@:-main.tex}
        '';

        compile_fast_auto = pkgs.writeShellScript "auto_compile_script" ''
          ${pkgs.watchexec}/bin/watchexec -e tex,bib ${compile_fast} ''${@:-main.tex}
        '';

        bib_clean = pkgs.writeShellScript "clean_bibliography" ''
          ${pkgs.bibclean}/bin/bibclean \
            -align-equals \
            -brace-protect \
            -check-values \
            -fix-accents \
            -fix-initials \
            -fix-names \
            -output-file $1 <(cat $1) 
        '';

        bib_tidy = pkgs.writeShellScript "tidy_bibliography" ''
          ${pkgs.bibtex-tidy}/bin/bibtex-tidy \
            --omit=doi,isbn,issn,url,abstract,bibtex_show,air,pdf \
            --curly \
            --numeric \
            --tab \
            --align=13 \
            --duplicates=key,doi,citation \
            --no-remove-dupe-fields \
            --sort-fields \
            --sort=-year $1
        '';

        pdf_builder = tex_file:
          let pdf_file = builtins.replaceStrings [ ".tex" ] [ ".pdf" ] tex_file;
          in pkgs.stdenvNoCC.mkDerivation {
            name = "${pdf_file}";
            src = self;
            buildInputs = [ texScheme pkgs.coreutils ];
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = "${compile} ${tex_file}";
            installPhase = "install ${pdf_file} $out";
          };
      in
      {
        packages = rec {
          # default = release;
          default = document;

          document = pdf_builder "main.tex";

          # biography = pdf_builder "biography.tex";

          # coverletter = pdf_builder "coverletter.tex";

          # release = pkgs.linkFarm "paper" [
          #   { name = "document.pdf"; path = document; }
          #   { name = "biography.pdf"; path = biography; }
          #   { name = "coverletter.pdf"; path = coverletter; }
          # ];
        };

        apps = {
          default = {
            type = "app";
            program = "${compile_auto}";
          };
          compile = {
            type = "app";
            program = "${compile}";
          };
          fast_compile = {
            type = "app";
            program = "${compile_fast}";
          };
          auto_compile = {
            type = "app";
            program = "${compile_auto}";
          };
          fast_auto_compile = {
            type = "app";
            program = "${compile_fast_auto}";
          };
          clean_bibliography = {
            type = "app";
            program = "${bib_clean}";
          };
          tidy_bibliography = {
            type = "app";
            program = "${bib_tidy}";
          };
        };

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = builtins.path {
              name = "flake-templates-src";
              path = ./.;
            };
            hooks = {
              deadnix.enable = true;
              nix-linter.enable = true;
              nixpkgs-fmt.enable = true;
              statix.enable = true;
              ci-lint = {
                enable = true;
                name = "ci lint";
                entry = "${pkgs.glab}/bin/glab ci lint";
                files = "\\.gitlab-ci.yml";
                pass_filenames = false;
              };
              nix-build = {
                enable = true;
                name = "nix build --no-link";
                entry = "nix build";
                files = "\\.(tex|pdf|tikz|png|jpg)";
                pass_filenames = false;
              };
            };
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ texScheme pkgs.watchexec ];
          shellHook = ''
            ${self.checks.${system}.pre-commit-check.shellHook}
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
