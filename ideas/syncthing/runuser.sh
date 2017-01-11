#/bin/sh

export all_proxy=socks5://127.0.0.1:4343

STTRACE=relay syncthing -home=/var/lib/syncthing-$USER

