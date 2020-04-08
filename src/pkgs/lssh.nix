{pkgs}:
pkgs.writeShellScriptBin "lssh" ''
#!/bin/sh

set -e -x

T="$1"
shift

IF=`ssh "$T" route -n | tail -n 1 | awk '{print $(NF)}'`
IP=`ssh "$T" ip -4 -o addr show $IF | awk '{print $4}' | sed 's/\/.*//'`

ssh -Y "$@"  "$IP"
''



