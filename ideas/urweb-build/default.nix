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
      trimmed = concatStringsSep "-" ( drop 1 (splitString "-" x));
    in
    if ((stringLength x) < 30) || (trimmed == "")
      then x
      else trimmed;

  uwModuleName = src :
    with lib; with builtins;
      replaceStrings ["-" "." "\n"] ["_" "_" ""] (
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

      mkLib = l :
        let
          lib = "${import "${builtins.toPath l}/build.nix"}";
        in
        ''
          echo "library ${lib}" >> lib.urp.header
        '';

      mkLib2 = l :
        ''
          echo "library ${l}" >> lib.urp.header
        '';

      mkEmbed_ = { css ? false, js ? false } : file :
        let

          sn = clearNixStore (uwModuleName file);
          snc = "${sn}_c";
          snj = "${sn}_j";
          flag_css = if css then "--css-mangle-urls" else "";
          flag_js = if js then "-j ${snj}.urs" else "";

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
                ${urembed} -c ${snc}.c -H ${snc}.h -s ${snc}.urs  -w ${sn}.ur ${flag_css} ${flag_js} ${file}
                echo 'ffi ${snc}'
                echo 'include ${snc}.h'
                echo 'link ${snc}.o'
                ${if js then "echo 'ffi ${snj}'" else ""}
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

        in
        ''
        cp ${o}/*c ${o}/*h ${o}/*urs ${o}/*ur ${o}/*o .
        cat ${o}/lib.urp.header >> lib.urp.header
        echo ${uwModuleName e.urFile} >> lib.urp.body
        '';

      mkEmbed = mkEmbed_ {} ;
      mkEmbedCSS = mkEmbed_ { css = true; };
      mkEmbedJS = mkEmbed_ { js = true; };

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
            mkdir -pv $out
            cd $out

            set -x

            echo -n > lib.urp.header
            echo -n > lib.urp.body

            ${concatStrings header}
            ${concatStrings body}

            cat lib.urp.header >> lib.urp
            echo >> lib.urp
            cat lib.urp.body >> lib.urp
            # rm lib.urp.header lib.urp.body
          '';
        };

      mkUrpExe = {name, body, header ? []} :
        with lib; with builtins;
        stdenv.mkDerivation {
          name = "urweb-exe-${name}";
          buildCommand = ''
            . $stdenv/setup
            mkdir -pv $out
            cd $out

            set -x

            echo -n > lib.urp.header
            echo -n > lib.urp.body

            ${concatStrings header}
            ${concatStrings body}

            {
              cat lib.urp.header
              echo
              cat lib.urp.body
            } > ${name}.urp
            # rm lib.urp.header lib.urp.body

            cat ${name}.urp
            ls

            ${urweb}/bin/urweb -dbms postgres ${name}

          '';
        };
    };
  };

in
  defs.public
