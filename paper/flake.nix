{
  description = "Paper flake";

  nixConfig.extra-substituters = [ "https://tweag-jupyter.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [
    "tweag-jupyter.cachix.org-1:UtNH4Zs6hVUFpFBTLaA4ejYavPo5EFFqgd7G7FxGW9g="
  ];

  inputs = {
    dotfiles.url = "gitlab:bertof/nix-dotfiles";
    nixpkgs.follows = "dotfiles/nixpkgs-u";
    jupyenv.url = "github:tweag/jupyenv";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    gitignore.url = "github:hercules-ci/gitignore.nix";
  };

  outputs =
    inputs:
    let
      ignored_source = inputs.gitignore.lib.gitignoreSource ./.;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.pre-commit-hooks-nix.flakeModule ];
      perSystem = { config, pkgs, system, lib, ... }:
        let
          textidote_jar = builtins.fetchurl {
            url = "https://github.com/sylvainhalle/textidote/releases/download/v0.8.3/textidote.jar";
            sha256 = "sha256:1ngf8bm8lfv551vqwgmgr85q17x20lfw0lwzz00x3a6m7b02r1h4";
          };
          texScheme = pkgs.texlive.combined.scheme-full;
          latexmk_args = "-pdf";
          compile = pkgs.writeShellScript "compile" ''
            set -e
            PATH=$PATH:${pkgs.lib.makeBinPath [ texScheme ]}
            latexmk -interaction=nonstopmode ${latexmk_args} $@
          '';
          continuous_compile = pkgs.writeShellScript "continuous_compile" ''
            set -e
            PATH=$PATH:${pkgs.lib.makeBinPath [ texScheme ]}
            latexmk -interaction=nonstopmode -pvc -synctex=1 ${latexmk_args} ''${@:-main}
          '';
          textidote = pkgs.writeShellScript "textidote-default" ''
            ${pkgs.jre}/bin/java -jar ${textidote_jar} --output html --firstlang en --check en ''${@:-main.tex} > textidote.html
          '';
          bibexport = pkgs.writeShellScript "bibexport_script" ''
            ${pkgs.texlive.combined.scheme-full}/bin/bibexport ''${@:-main}
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
          pdf_builder = { src ? ignored_source, makeglossary ? [ ] }: pkgs.stdenvNoCC.mkDerivation {
            name = "documents";
            inherit src;
            TEXMFCACHE = ".cache/";
            buildInputs = [ texScheme ];
            buildPhase = builtins.concatStringsSep "\n" ([
              "export HOME=$(mktemp -d)\n"
              (toString compile)
            ] ++ (map (f: "makeglossary ${f}") makeglossary) ++ [
              (toString compile)
            ]);
            installPhase = ''
              mkdir $out
              install *.pdf $out
            '';
          };
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
                  entry = "${compile}";
                  files = "\\.(tex|pdf|tikz|png|jpg)";
                  pass_filenames = false;
                };

              };
            };
          };

          packages = {
            inherit texScheme;
            default = pdf_builder { src = ./.; };
            jupyter-lab =
              let
                inherit (inputs.jupyenv.lib.${system}) mkJupyterlabNew;
              in
              mkJupyterlabNew ({ ... }: {
                inherit (inputs) nixpkgs;
                imports = [
                  (_: {
                    kernel.python.minimal = {
                      enable = true;
                      extraPackages = ps: [
                        ps.seaborn
                        ps.pandas
                        ps.humanfriendly
                      ];
                    };
                  })
                ];
              });
          };

          apps = {
            default = { type = "app"; program = "${continuous_compile}"; };
            continuous_compile = { type = "app"; program = "${continuous_compile}"; };
            bibexport = { type = "app"; program = "${bibexport}"; };
            textidote = { type = "app"; program = "${textidote}"; };
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
