#!/bin/sh

nix-build src/pkgs/myenv.nix --argstr me $USER && nix-env -i ./result
