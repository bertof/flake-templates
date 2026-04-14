{
  description = "Typst paper flake";

  inputs = {
    systems.url = "github:nix-systems/default";
    dotfiles.url = "gitlab:bertof/nix-dotfiles";
    nixpkgs.follows = "dotfiles/nixpkgs-u";
    flake-parts.follows = "dotfiles/flake-parts";
    git-hooks.follows = "dotfiles/git-hooks";
    press.url = "github:RossSmyth/press/a197eaa606fb53fc0977c954fa6bbf3b07ab8ed5";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.git-hooks.flakeModule ];
      perSystem =
        { pkgs
        , config
        , self'
        , system
        , ...
        }:
        let
          bib-tidy = pkgs.writeShellScript "bib-tidy-default" ''
            ${pkgs.bibtex-tidy}/bin/bibtex-tidy \
            --omit=isbn,issn,url,bibtex_show,air,pdf,urldate \
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
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.press.overlays.default ];
          };

          pre-commit = {
            inherit pkgs;
            settings = {
              hooks = {
                # Nix
                deadnix.enable = true;
                nixfmt.enable = true;
                statix.enable = true;
                flake-checker.enable = true;

                # GitLab
                ci-lint = {
                  enable = true;
                  name = "ci lint";
                  entry = "${pkgs.glab}/bin/glab ci lint";
                  files = "\\.gitlab-ci.yml";
                  pass_filenames = false;
                };

                # Typst
                typstyle.enable = true;

                # Markdown
                mdformat.enable = true;
                markdownlint.enable = true;
              };
            };
          };

          packages = {
            slides = pkgs.buildTypstDocument {
              name = "slides";
              src = ./.;
              file = "slides.typ";
              typstEnv = p: [
                p.oxifmt_0_2_1
                p.fletcher_0_5_8
                p.touying_0_6_1
              ];
              fonts = [
                pkgs.liberation_ttf
              ];
              preBuild = ''
                unset SOURCE_DATE_EPOCH
              '';
            };
          };

          apps = {
            bib_tidy = {
              type = "app";
              program = "${bib-tidy}";
            };
            auto-compile = {
              type = "app";
              program = pkgs.writeShellScriptBin "play" ''
                PATH=$PATH:${pkgs.lib.makeBinPath self'.devShells.default.nativeBuildInputs}
                typst watch ''${@:-main.typ}
              '';
            };
            play = {
              type = "app";
              program = pkgs.writeShellScriptBin "play" ''
                ${pkgs.pympress}/bin/pympress ''${@:-main.pdf}
              '';
            };
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ config.pre-commit.devShell ];
            packages = with pkgs; [
              tinymist
              typst
              typstyle
              libertinus
            ];
            shellHook = ''
              unset SOURCE_DATE_EPOCH
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
