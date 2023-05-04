{
  description = "Paper flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks, gitignore }: flake-utils.lib.eachDefaultSystem (system:
    let
      source_path = builtins.path { path = ./.; name = "paper-src"; };
      ignored_source = gitignore.lib.gitignoreSource source_path;
      pkgs = import nixpkgs { inherit system; };
      # texScheme = pkgs.texlive.combined.scheme-full;
      texScheme = pkgs.callPackage ./tex-env.nix {
        extraTexPackages = { inherit (pkgs.texlive) scheme-medium ieeetran; };
      };
      textidote_jar = builtins.fetchurl {
        url = "https://github.com/sylvainhalle/textidote/releases/download/v0.8.3/textidote.jar";
        sha256 = "sha256:1ngf8bm8lfv551vqwgmgr85q17x20lfw0lwzz00x3a6m7b02r1h4";
      };

      tex_env_setup = ''
        export PATH="${pkgs.lib.makeBinPath [texScheme pkgs.coreutils]}";
        export TEXMFHOME=.cache
        export TEXMFVAR=.cache/texmf-var
        mkdir -p $TEXMFVAR
      '';

      compile_cleanup = pkgs.writeShellScript "compile_cleanup" ''
        ${tex_env_setup}
        latexmk -c ''${1:-main.tex}
      '';

      compile = pkgs.writeShellScript "compile_script" ''
        ${tex_env_setup}
        latexmk -interaction=nonstopmode -pdflua ''${1:-main.tex}
      '';

      auto_compile = pkgs.writeShellScript "auto_compile_script" ''
        ${compile_cleanup} ''${1:-main.tex}
        ${compile} ''${1:-main.tex}
        ${pkgs.watchexec}/bin/watchexec -r -e tex,bib ${compile} ''${1:-main.tex}
      '';

      auto_run = pkgs.writeShellScript "auto_run" ''
        ${pkgs.watchexec}/bin/watchexec -r -e nix 'nix run .#auto_compile ''${1:-main.tex}'
      '';

      textidote = pkgs.writeShellScript "textidote" ''
        ${pkgs.jre}/bin/java -jar ${textidote_jar} --output html --firstlang en --check en ''${1:-main.tex} > textidote.html
      '';

      bib_clean = pkgs.writeShellScript "bib_clean" ''
        ${pkgs.bibclean}/bin/bibclean \
          -align-equals \
          -brace-protect \
          -check-values \
          -fix-accents \
          -fix-initials \
          -fix-names \
          -output-file ''${1:-biblio.bib} <(cat ''${1:-biblio.bib}) 
      '';

      bib_tidy = pkgs.writeShellScript "bib_tidy" ''
        ${pkgs.bibtex-tidy}/bin/bibtex-tidy \
          --omit=doi,isbn,issn,url,abstract,bibtex_show,air,pdf \
          --curly \
          --numeric \
          --tab \
          --align=13 \
          --duplicates=key,doi,citation \
          --no-remove-dupe-fields \
          --sort-fields \
          --sort=-year ''${1:-biblio.bib}
      '';

      pdf_builder = { src ? ignored_source, tex_file ? "main.tex" }:
        let
          pdf_file = builtins.replaceStrings [ ".tex" ] [ ".pdf" ] tex_file;
        in
        pkgs.stdenvNoCC.mkDerivation {
          name = "${pdf_file}";
          inherit src;
          buildInputs = [ texScheme pkgs.coreutils ];
          buildPhase = "${compile} ${tex_file}";
          installPhase = "install ${pdf_file} $out";
        };
    in
    {
      packages = rec {
        default = release;
        document = pdf_builder { tex_file = "main.tex"; };
        # biography = pdf_builder { tex_file = "bibliography.tex"; };
        # coverletter = pdf_builder { tex_file = "coverletter.tex"; };
        release = pkgs.linkFarm "paper" [
          { name = "document.pdf"; path = document; }
          # { name = "biography.pdf"; path = biography; }
          # { name = "coverletter.pdf"; path = coverletter; }
        ];
      };

      apps = {
        default = { type = "app"; program = "${auto_compile}"; };
        compile = { type = "app"; program = "${compile}"; };
        auto_compile = { type = "app"; program = "${auto_compile}"; };
        auto_run = { type = "app"; program = "${auto_run}"; };
        textidote = { type = "app"; program = "${textidote}"; };
        bib_clean = { type = "app"; program = "${bib_clean}"; };
        bib_tidy = { type = "app"; program = "${bib_tidy}"; };
      };

      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ignored_source;
          tools = {
            chktex = texScheme;
            latexindent = texScheme;
          };
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
              entry = "nix build --no-link";
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
