# flake-templates

A collection of [Nix flake](https://nixos.wiki/wiki/Flakes) templates
for quickly starting new projects with a reproducible development
environment and pre-commit checks already wired up.

Every template ships with:

- a `flake.nix` providing a development shell (`nix develop`);
- [git-hooks.nix](https://github.com/cachix/git-hooks.nix) integration
  running the hooks through [prek](https://github.com/j178/prek) in
  parallel (Nix linting/formatting, typos, and language-specific hooks
  where relevant);
- a `flake.lock` pinning all inputs;
- [rbw-env](https://github.com/bertof/rbw-env) integration to load
  environment variables from [Vaultwarden](https://github.com/dani-garcia/vaultwarden)
  via [rbw](https://github.com/doy/rbw), in the templates that need it.

## Available templates

- `basic`: basic flake environment with pre-commit checks
- `python`: Python development environment
- `rust`: Rust library
- `latex`: LaTeX document
- `paper-latex`: LaTeX paper
- `paper-typst`: IEEE paper based on Typst
- `presentation-latex`: LaTeX (Beamer) presentation
- `presentation-typst`: Typst presentation with pre-commit checks
- `presentation-typst-cern`: Typst presentation with CERN's template
- `thesis`: LaTeX thesis

## Usage

Initialize a new project from a template:

```bash
nix flake init -t github:bertof/flake-templates#<template>
```

or create a new directory:

```bash
nix flake new -t github:bertof/flake-templates#<template> my-project
```

Then enter the development environment:

```bash
nix develop
```

Entering the shell also installs the git hooks (via prek). If you use
[direnv](https://direnv.net/) (recommended), simply run `direnv allow`
and the environment activates automatically when you `cd` into the
project.

## Pre-commit hooks

Hooks are managed declaratively in each template's `flake.nix` and
rendered to `.pre-commit-config.yaml` by
[git-hooks.nix](https://github.com/cachix/git-hooks.nix); do not edit
the generated file. If you add or modify hooks, re-enter the
development shell (or run `nix develop`) to regenerate and reinstall
them.

To run all hooks manually:

```bash
prek run --all-files
```

## Repository development

This repository itself uses the same toolchain: `nix develop` provides
the environment and installs the prek hooks, and `nix fmt` (nixpkgs-fmt)
formats the Nix sources.
