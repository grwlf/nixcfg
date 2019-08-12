Setting up the environment
==========================

### Installing the system configuration

1. Export the Nix paths via the `NIX_PATH` variable
   ```
   export NIX_DEV_ROOT=$HOME/proj/nixcfg
   export NIX_PATH="nixpkgs=$NIX_DEV_ROOT/nixpkgs:nixos=$NIX_DEV_ROOT/nixpkgs/nixos:nixos-config=$NIX_DEV_ROOT/src/ww.nix:services=/etc/nixos/services:passwords=$NIX_DEV_ROOT/pass"
   ```

2. Building the profile
   ```
   $ nixos-rebuild
   ```

### Installing user profile

1. Install the profile:
    ```
   $ nix-build src/pkgs/myenv.nix
   $ nix-env -i ./result
   ```
2. Link profile's bashrc with user `.bashrc`
   ```
   if test -f "$HOME/.nix-profile/etc/myprofile" ; then
     . "$HOME/.nix-profile/etc/myprofile"
   fi
   ```


