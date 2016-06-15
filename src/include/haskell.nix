{ config, pkgs, ... } :

let mypkgs = a : with a ; [
  cabal-install
  alex
  happy
  parsec
  optparse-applicative
  hasktags];

in

{

  nixpkgs.config = {

    packageOverrides = pkgs: {

      haskell-lts221 = (pkgs.haskell.packages.lts-2_21.override {
        overrides = config.haskellPackageOverrides or (self: super: {});
      }).ghcWithPackages mypkgs;

      haskell-latest = (pkgs.haskell.packages.lts-4_2.override {
        overrides = config.haskellPackageOverrides or (self: super: {});
      }).ghcWithPackages mypkgs;

      haskell-latest-profiling = (pkgs.haskell.packages.lts-4_2.override {
        overrides = config.haskellPackageOverrides or (self: super: {

          mkDerivation = args: super.mkDerivation (args // {
            enableLibraryProfiling = true;
          });

        });
      }).ghcWithPackages mypkgs;

    };
  };
}

