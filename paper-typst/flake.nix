{
  description = "Typst paper flake";

  inputs = {
    systems.url = "github:nix-systems/default";
    dotfiles.url = "gitlab:bertof/nix-dotfiles";
    nixpkgs.follows = "dotfiles/nixpkgs-u";
    flake-parts.follows = "dotfiles/flake-parts";
    git-hooks.follows = "dotfiles/git-hooks";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [ inputs.git-hooks.flakeModule ];
    perSystem = { config, pkgs, lib, ... }:
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
        pre-commit = {
          inherit pkgs;
          settings = {
            hooks = {
              deadnix.enable = true;
              nixpkgs-fmt.enable = true;
              statix.enable = true;

              ci-lint = {
                enable = true;
                name = "ci lint";
                entry = "${pkgs.glab}/bin/glab ci lint";
                files = "\\.gitlab-ci.yml";
                pass_filenames = false;
              };

              typstyle = {
                enable = true;
                name = "typstyle";
                entry = "${pkgs.typstyle}/bin/typstyle format-all";
                files = "\\.typ$";
                pass_filenames = false;
              };
            };
          };
        };

        packages = {
          typst-compile = pkgs.writeShellScriptBin "typst-compile" ''
            PATH=$PATH:${pkgs.lib.makeBinPath [ pkgs.typst ]}
            typst compile ''${@:-main.typ}
          '';
        };

        apps = {
          bib_tidy = { type = "app"; program = "${bib-tidy}"; };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ tinymist typst typstyle libertinus ];
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
