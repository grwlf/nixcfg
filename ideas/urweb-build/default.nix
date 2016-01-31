let
  pkgs = import <nixpkgs> {};

  urweb = pkgs.urweb;

  lib = pkgs.lib;

  trace = builtins.trace;

  removeUrSuffixes = s :
    with lib;
    removeSuffix ".ur" (removeSuffix ".urs" s);

  lastSegment = sep : str : lib.last (lib.splitString sep str);

  clearNixStore = x : builtins.readFile (builtins.toFile "tmp" x);

  calcFileName = src :
    with lib; with builtins;
    let
      x =  lastSegment "/" src;
    in
    if stringLength x < 30
      then x
      else concatStringsSep "-" ( drop 1 (splitString "-" x));

  uwModuleName = src :
    with lib; with builtins;
      replaceStrings ["-" "."] ["_" "_"] (
        calcFileName (removeUrSuffixes src)
      );

  defs =  rec {

    inherit (pkgs) stdenv lib;

    urembed = ./cake3/dist/build/urembed/urembed;

    public = rec {

      mkVerbose = txt : ''
          echo ${txt} >> lib.urp.header
        '';

      mkObj = file : ''
          UWCC=`${urweb}/bin/urweb -print-ccompiler`
          IDir=`${urweb}/bin/urweb -print-cinclude`
          CC=`$UWCC -print-prog-name=gcc`
          $CC -c -I$IDir -I. -o `basename ${file}`.o ${file}
          echo "link `basename ${file}`.o" >> lib.urp.header
        '';

      mkInclude = file : ''
          cp ${file} ${calcFileName file}
          echo "include ${calcFileName file}" >> lib.urp.header
        '';

      mkFFI = file : ''
          cp ${file} ${uwModuleName file}.urs
          echo "ffi ${uwModuleName file}" >> lib.urp.header
        '';

      mkLib = file : let
          l =
            trace "loading lib ${file}"
                  "${import "${file}/build.nix"}/lib.urp";
        in
        ''
          echo "library ${l}" >> lib.urp.header
        '';

      mkEmbed = file :
        let

          sn = clearNixStore (uwModuleName file);
          snc = "${sn}_c";

          e = rec {
            urFile = "${out}/${sn}.ur";
            urpFile = "${out}/lib.urp.header";

            out = stdenv.mkDerivation {
              name = "embed-${sn}";
              buildCommand = ''
                . $stdenv/setup
                mkdir -pv $out ;
                cd $out

                (
                ${urembed} -c ${snc}.c -H ${snc}.h -s ${snc}.urs  -w ${sn}.ur ${file}
                echo 'ffi ${snc}.urs'
                echo 'include ${snc}.h'
                echo 'link ${snc}.o'
                ) > lib.urp.header

                UWCC=`${urweb}/bin/urweb -print-ccompiler`
                IDir=`${urweb}/bin/urweb -print-cinclude`
                CC=`$UWCC -print-prog-name=gcc`

                echo $CC -c -I$IDir -o ${snc}.o ${snc}.c
                $CC -c -I$IDir -o ${snc}.o ${snc}.c

              '';
            };
          };

          o = e.out;

        in ''
        cp ${o}/*c ${o}/*h ${o}/*urs ${o}/*ur ${o}/*o .
        cat ${o}/lib.urp.header >> lib.urp.header
        echo ${uwModuleName e.urFile} >> lib.urp.body
        '';

      # FIXME: implement embedding for CSS and JS
      mkEmbedCSS = mkEmbed;
      mkEmbedJS = mkEmbed;

      mkSrc = ur : urs : ''
        cp ${ur} `echo ${ur} | sed 's@.*/[a-z0-9]\+-\(.*\)@\1@'`
        cp ${urs} `echo ${urs} | sed 's@.*/[a-z0-9]\+-\(.*\)@\1@'`
        echo ${uwModuleName ur} >> lib.urp.body
        '';

      mkSrc1 = ur : ''
        cp ${ur} `echo ${ur} | sed 's@.*/[a-z0-9]\+-\(.*\)@\1@'`
        echo ${uwModuleName ur} >> lib.urp.body
        '';

      mkSys = nm : ''
        echo $/${nm} >> lib.urp.body
        '';

      mkUrpLib = {name, body, header ? []} :
        with lib; with builtins;
        stdenv.mkDerivation {
          name = "urweb-lib-${name}";
          buildCommand = ''
            . $stdenv/setup
            mkdir -pv $out ; cd $out

            set -x

            echo -n > lib.urp.header
            echo -n > lib.urp.body

            ${concatStrings header}
            ${concatStrings body}

            cat lib.urp.header >> lib.urp
            echo >> lib.urp
            cat lib.urp.body >> lib.urp
            rm lib.urp.header lib.urp.body
          '';
        };
    };
  };

in
  defs.public
