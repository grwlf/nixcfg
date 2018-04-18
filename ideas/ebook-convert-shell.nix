{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
    fhs = pkgs.buildFHSUserEnv {

        name = "chroot-pandoc";
        targetPkgs = pkgs: with pkgs; [
            (texlive.combine {inherit (texlive) scheme-small enumitem ucs bibtex xetex collection-langcyrillic; })
            pandoc
            calibre
        ];
        multiPkgs = pkgs: with pkgs; [
            zlib
        ];
        runScript = "bash";
        profile = ''
        '';
    };

in
stdenv.mkDerivation {
  name = "chroot-pandoc";
  nativeBuildInputs = [ fhs ];
  shellHook = "exec chroot-pandoc";
}

