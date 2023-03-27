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
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };

      # texScheme = pkgs.texlive.combined.scheme-full;
      texScheme = pkgs.callPackage ./tex-env.nix {
        extraTexPackages = { inherit (pkgs.texlive) scheme-medium ieeetran datatool makecell; };
      };

      textodite_jar = builtins.fetchurl {
        url = "https://github.com/sylvainhalle/textidote/releases/download/v0.8.3/textidote.jar";
        sha256 = "sha256:1ngf8bm8lfv551vqwgmgr85q17x20lfw0lwzz00x3a6m7b02r1h4";
      };

      tex_env_setup = ''
        export PATH="${pkgs.lib.makeBinPath [texScheme pkgs.coreutils]}";
        mkdir -p .cache/texmf-var
        export TEXMFHOME=.cache
        export TEXMFVAR=.cache/texmf-var
      '';

      compile = pkgs.writeShellScript "compile_script" ''
        ${tex_env_setup}
        latexmk -c -interaction=nonstopmode -pdflua ''${@:-main.tex}
      '';

      fast_compile = pkgs.writeShellScript "compile_script" ''
        ${tex_env_setup}
        latexmk -interaction=nonstopmode -pdflua ''${@:-main.tex}
      '';

      auto_compile = pkgs.writeShellScript "auto_compile_script" ''
        ${pkgs.watchexec}/bin/watchexec -e tex,bib ${compile} ''${@:-main.tex}
      '';

      fast_auto_compile = pkgs.writeShellScript "auto_compile_script" ''
        ${pkgs.watchexec}/bin/watchexec -e tex,bib ${fast_compile} ''${@:-main.tex}
      '';

      textodite = pkgs.writeShellScript "run_textodite" ''
        export PATH="${pkgs.lib.makeBinPath [pkgs.jre]}";
        java -jar ${textodite_jar} --output html --firstlang en --check en main.tex > out.html
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
        let
          pdf_file = builtins.replaceStrings [ ".tex" ] [ ".pdf" ] tex_file;
        in
        pkgs.stdenvNoCC.mkDerivation {
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

        default = release;

        document = pdf_builder "main.tex";

        # biography = pdf_builder "biography.tex";

        # bio_img = pdf_builder "bio_img.tex";

        # coverletter = pdf_builder "coverletter.tex";

        # highlights = pdf_builder "highlights.tex";

        # answer = pdf_builder "answer.tex";

        release = pkgs.linkFarm "release" [
          { name = "document.pdf"; path = document; }
        ];
      };

      apps = {
        default = { type = "app"; program = "${auto_compile}"; };
        compile = { type = "app"; program = "${compile}"; };
        fast_compile = { type = "app"; program = "${fast_compile}"; };
        auto_compile = { type = "app"; program = "${auto_compile}"; };
        fast_auto_compile = { type = "app"; program = "${fast_auto_compile}"; };
        clean_bibliography = { type = "app"; program = "${bib_clean}"; };
        tidy_bibliography = { type = "app"; program = "${bib_tidy}"; };
        textodite = { type = "app"; program = "${textodite}"; };
      };

      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
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
