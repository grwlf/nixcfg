#!/bin/sh

CWD=`pwd`

parse() {
  U=`echo $1 | tr ':@' '  ' | awk '{print $1}'`
  P=`echo $1 | tr ':@' '  ' | awk '{print $2}'`
  H=`echo $1 | tr ':@' '  ' | awk '{print $3}'`
  Po=`echo $1 | tr ':@' '  ' | awk '{print $4}'`
}

parse $http_proxy

cat >cfg.client <<EOF
cert=$CWD/stunnel.pem
pid=$CWD/stunnel.pid
client=yes
# setuid = stunnel
# setgid = stunnel
foreground = yes
output = /dev/stdout
debug = 7
[ssh]
accept=443
connect=46.38.250.132:443
# protocol = connect
# protocolUsername = $U
# protocolPassword = $P
# connect=$H:$Po
EOF

stunnel cfg.client

