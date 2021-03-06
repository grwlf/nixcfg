What's this?
============

This project is basically a collection of author's configuraiton in form of Nix
expressions.

Install
-------

### Installing the whole-system configuration

1. Export the Nix paths via the `NIX_PATH` variable. Add the following lines to
   your `~/.bashrc`:
   ```
   export NIXCFG_ROOT=\
   $HOME/proj/nixcfg

   export NIX_PATH=\
   localpkgs=$NIXCFG_ROOT/src/pkgs/localpkgs.nix:\
   nixpkgs=$NIXCFG_ROOT/nixpkgs:\
   nixos=$NIXCFG_ROOT/nixpkgs/nixos:\
   nixos-config=$NIXCFG_ROOT/src/samsung-np900x3c.nix:\
   passwords=$NIXCFG_ROOT/passwords

   alias nix-env="nix-env -f '<nixpkgs>'"
   ```

2. Build the profile. Create missing password files if required.
   ```
   $ nixos-rebuild
   ```

### Installing user profile

1. Install the profile:
    ```
   $ nix-build src/pkgs/myenv.nix --argstr me $USER
   $ nix-env -i ./result
   ```
2. Link profile's bashrc with user `.bashrc`
   ```
   if test -f "/home/$USER/.nix-profile/etc/myprofile" ; then
     . "/home/$USER/.nix-profile/etc/myprofile"
   fi
   ```


Resources
---------


### E-Mail

* [Mutt](http://www.mutt.org)
* [MBSync](https://linux.die.net/man/1/mbsync)
* [Protonmail bridge (paid)](https://protonmail.com/support/knowledge-base/bridge-for-linux/)

