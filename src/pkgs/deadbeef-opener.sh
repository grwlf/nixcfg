#!/bin/sh
date >/tmp/lyricsbar.log
echo "$0: $@" >>/tmp/lyricsbar.log

# set -x
if test "$1" == "--lyrics" ; then
  shift
  if test -n "$1" ; then
    ARTIST="$1"
    ARTIST2="`echo "$ARTIST" | sed 's@^[Tt]he @@' | sed 's@ \?(.*).*@@'`"
    echo "ARTIST: $ARTIST, $ARTIST2">&2
    shift
    if test -n "$1" ; then
      TITLE="$1"
      TITLE2="`echo "$TITLE" | sed 's@^[Tt]he @@' | sed 's@ \?(.*).*@@'`"
      echo "TITLE: $TITLE, $TITLE2">&2
      shift
      if test -n "$1" ; then
        COMPOSER="$1"
        COMPOSER2="`echo "$COMPOSER" | sed 's@^[Tt]he @@' | sed 's@ \?(.*).*@@'`"
        echo "COMPOSER: $COMPOSER, $COMPOSER2">&2
        shift
      fi
    fi
  fi

  rm $HOME/.cache/deadbeef/lyrics/*

  IFS=$'\n'
  for a in "$ARTIST" "$ARTIST2" "$COMPOSER" "$COMPOSER2"; do
    for t in "$TITLE" "$TITLE2" ; do
      echo "SEARCHING: '$a' '$t'" >&2
      for f in `find \
          "$HOME/doc/Музыка/Аккорды/" \
          "$HOME/pers/Тексты/" \
          "$HOME/pers/Репертуар/" \
          -type f \
          -iname "*$a*" -a -iname "*$t*" -a -iname '*txt'` ; do
        rm $HOME/.cache/deadbeef/lyrics/*
        cat "$f"
        exit
      done
    done
  done

elif test "$1" == "--scores" ; then
  shift
  FILE=`basename "$1"`
  echo "$FILE">&2
  ARTIST=`echo "$FILE" | sed "s@'@@" | sed 's@^[Tt]he @@' | sed 's@\(.*\) -.*@\1@'`
  echo "$ARTIST">&2
  TITLE=`echo "$FILE" | sed "s@'@@" | sed 's@^[Tt]he @@' | sed 's@ *(.*) *@@' | sed 's@.*- *\(.*\)\..*@\1@'`
  echo "$TITLE">&2

  IFS=$'\n'
  for a in "$ARTIST" ; do
    for t in "$TITLE" ; do
      for f in `find \
          "$HOME/doc/Музыка/Аккорды/" \
          "$HOME/pers/Тексты/" \
          "$HOME/pers/Репертуар/" \
          -type f \
          -iname "*$a*" -a -iname "*$t*" -a -iname '*pdf'` ; do
        echo "FOUND $f" >&2
        evince "$f" >/dev/null 2>&1 &
        exit
      done
    done
  done

else
  echo "Unknown first argument: '$1'" >&2
  exit 1
fi

