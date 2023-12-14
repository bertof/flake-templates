{
  description = "Thesis flake";

  inputs = {
    # dotfiles.url = "gitlab:bertof/nix-dotfiles";
    # nixpkgs.follows = "dotfiles/nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    gitignore.url = "github:hercules-ci/gitignore.nix";
  };

  outputs = inputs:
    let
      ignored_source = inputs.gitignore.lib.gitignoreSource ./.;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.pre-commit-hooks-nix.flakeModule ];
      perSystem =
        { config
          # , self'
          # , inputs'
        , pkgs
          # , system
        , lib
        , ...
        }:
        let
          textidote_jar = builtins.fetchurl {
            url = "https://github.com/sylvainhalle/textidote/releases/download/v0.8.3/textidote.jar";
            sha256 = "sha256:1ngf8bm8lfv551vqwgmgr85q17x20lfw0lwzz00x3a6m7b02r1h4";
          };
          texScheme = pkgs.texlive.combined.scheme-full;
          latexmk_args = "-pdflua";
          cleanup = pkgs.writeShellScript "cleanup" ''
            set -e
            PATH=$PATH:${pkgs.lib.makeBinPath [ texScheme ]}
            latexmk -c ${latexmk_args} ''${@:-main}
          '';
          compile = pkgs.writeShellScript "compile" ''
            set -e
            PATH=$PATH:${pkgs.lib.makeBinPath [ texScheme ]}
            latexmk -interaction=nonstopmode ${latexmk_args} ''${@:-main}
          '';
          continuous_compile = pkgs.writeShellScript "continuous_compile" ''
            set -e
            PATH=$PATH:${pkgs.lib.makeBinPath [ texScheme ]}
            latexmk -interaction=nonstopmode -pvc -synctex=1 ${latexmk_args} ''${@:-main}
          '';
          auto_run = pkgs.writeShellScript "auto_run" ''
            set -e
            ${pkgs.watchexec}/bin/watchexec -r -e nix 'nix run .#continuous_compile ''${@:-main}'
          '';
          textidote = pkgs.writeShellScript "textidote-default" ''
            ${pkgs.jre}/bin/java -jar ${textidote_jar} --output html --firstlang en --check en ''${@:-main.tex} > textidote.html
          '';
          bibexport = pkgs.writeShellScript "bibexport_script" ''
            ${texScheme}/bin/bibexport $@
          '';
          bibclean = pkgs.writeShellScript "bibclean-default" ''
            ${pkgs.bibclean}/bin/bibclean \
              -align-equals \
              -brace-protect \
              -check-values \
              -fix-accents \
              -fix-initials \
              -fix-names \
              -output-file ''${1:-biblio.bib} <(cat ''${1:-biblio.bib}) 
          '';
          bib-tidy = pkgs.writeShellScript "bib-tidy-default" ''
            ${pkgs.bibtex-tidy}/bin/bibtex-tidy \
            --omit=doi,isbn,issn,url,bibtex_show,air,pdf,urldate \
            --curly \
            --numeric \
            --tab \
            --months \
            --duplicates=key,doi,citation \
            --no-remove-dupe-fields \
            --sort-fields \
            --sort=-year \
            --strip-comments \
            --remove-empty-fields \
            --wrap=1000 \
            --modify ''${@:-biblio.bib}
          '';
        in
        {
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          # # This sets `pkgs` to a nixpkgs with allowUnfree option set.
          # _module.args.pkgs = import inputs.nixpkgs {
          #   inherit system;
          #   overlays = [
          #     (self: _super: rec { })
          #   ];
          #   # config.allowUnfree = true;
          # };

          pre-commit = {
            inherit pkgs;
            settings = {
              hooks = {
                deadnix.enable = true;
                nixpkgs-fmt.enable = true;
                statix.enable = true;

                chktex.enable = true;
                latexindent.enable = true;

                ci-lint = {
                  enable = true;
                  name = "ci lint";
                  entry = "${pkgs.glab}/bin/glab ci lint";
                  files = "\\.gitlab-ci.yml";
                  pass_filenames = false;
                };
                nix-build = {
                  enable = true;
                  name = "nix build";
                  entry = "nix build --no-link --print-build-logs";
                  files = "\\.(tex|pdf|tikz|png|jpg)";
                  pass_filenames = false;
                };
              };
            };
          };

          packages =
            let
              pdf_builder = { src ? ignored_source, tex_file }:
                let
                  pdf_file = "${builtins.replaceStrings [ ".tex" ] [ ".pdf" ] tex_file}.pdf";
                in
                pkgs.stdenvNoCC.mkDerivation {
                  name = "${pdf_file}";
                  inherit src;
                  TEXMFCACHE = ".cache/";
                  buildInputs = [ texScheme ];
                  buildPhase = ''
                    ${compile} ${tex_file}
                    makeglossaries ${tex_file}
                    ${compile} ${tex_file}
                  '';
                  installPhase = "install ${pdf_file} $out";
                };
            in
            rec {
              inherit texScheme;
              default = release;
              document = pdf_builder { tex_file = "main"; };
              # biography = pdf_builder { tex_file = "bibliography"; };
              # coverletter = pdf_builder { tex_file = "coverletter"; };
              release = pkgs.linkFarm "release" [
                { name = "document.pdf"; path = document; }
                # { name = "coverletter.pdf"; path = coverletter; }
              ];
            };

          apps = {
            default = { type = "app"; program = "${continuous_compile}"; };
            continuous_compile = { type = "app"; program = "${continuous_compile}"; };
            auto_run = { type = "app"; program = "${auto_run}"; };
            cleanup = { type = "app"; program = "${cleanup}"; };
            bibexport = { type = "app"; program = "${bibexport}"; };
            textidote = { type = "app"; program = "${textidote}"; };
            bib_clean = { type = "app"; program = "${bibclean}"; };
            bib_tidy = { type = "app"; program = "${bib-tidy}"; };
          };

          devShells.default = pkgs.mkShell {
            packages = [ texScheme ];
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
