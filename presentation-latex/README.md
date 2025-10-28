# <Project name>

## Development environment

The file `flake.nix` provides a development environment with all the dependencies necessary for a Latex project.
To use it, execute `nix develop` on a computer with Nix enabled and configured to use flakes.
You can also use `direnv allow` for `direnv` to automatically load the development environment when you enter the folder.
The environment also sets up some commit hooks, in order to verify the commit correctness.

## Build

To build the documents use `nix build` or `nix buid --print-build-logs` if you want to show the build logs.

## CI

The CI starts a build of the default target and copies the results in the artifacts folder.