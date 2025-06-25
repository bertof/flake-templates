{
  description = "Latex flake";

  inputs = {
    systems.url = "github:nix-systems/default";
    dotfiles.url = "gitlab:bertof/nix-dotfiles";
    nixpkgs.follows = "dotfiles/nixpkgs-u";
    flake-parts.follows = "dotfiles/flake-parts";
    git-hooks-nix.follows = "dotfiles/git-hooks-nix";
    gitignore.url = "github:hercules-ci/gitignore.nix";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [ inputs.git-hooks-nix.flakeModule ];
    perSystem = { self', config, pkgs, lib, ... }:
      let
        latexmk_args = "-pdfxe";
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
              latexmk = {
                enable = true;
                name = "latexmk";
                entry = "${self'.packages.compile}/bin/compile";
                files = "\\.(tex|pdf|tikz|png|jpg)";
                pass_filenames = false;
              };
            };
          };
        };

        packages = {
          default =
            let ignored_source = inputs.gitignore.lib.gitignoreSource ./.;
            in pkgs.stdenvNoCC.mkDerivation {
              name = "documents";
              src = ignored_source;
              TEXMFCACHE = ".cache/";
              buildInputs = [ self'.packages.texScheme ];
              buildPhase = ''
                runHook preBuild
                export HOME=$(mktemp -d)
                ${self'.packages.compile}/bin/compile
                runHook postBuild
              '';
              installPhase = ''
                runHook preInstall
                mkdir $out
                install *.pdf $out
                runHook postInstall
              '';
            };
          texScheme = pkgs.texlive.combined.scheme-full;

          textidote-default = pkgs.writeShellScriptBin "textidote-default" ''
            ${pkgs.textidote}/bin/textidote --output html --firstlang en --check en ''${@:-main.tex} > textidote.html
          '';
          bibexport-default = pkgs.writeShellScriptBin "bibexport-default" ''
            ${pkgs.texlive.combined.scheme-full}/bin/bibexport -o export.bib ''${@:-main.aux}
          '';
          bibtex-tidy-default = pkgs.writeShellScriptBin "bibtex-tidy-default" ''
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
          compile = pkgs.writeShellScriptBin "compile" ''
              set -euo pipefail
            PATH=$PATH:${pkgs.lib.makeBinPath [ self'.packages.texScheme ]}
            latexmk -interaction=nonstopmode ${latexmk_args} $@
          '';
          continuous_compile = pkgs.writeShellScriptBin "continuous_compile" ''
            set -euo pipefail
            PATH=$PATH:${pkgs.lib.makeBinPath [ self'.packages.texScheme ]}
            latexmk -interaction=nonstopmode -pvc -synctex=1 ${latexmk_args} $@
          '';
        };

        apps.default.program = "${self'.packages.continuous_compile}/bin/continuous_compile";

        devShells.default = pkgs.mkShell {
          packages = [ self'.packages.texScheme pkgs.texlab ];
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
