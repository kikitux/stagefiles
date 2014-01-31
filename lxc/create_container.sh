#!/bin/bash
THISFILE=$(basename "${0}")
THISDIR=${0%lxc/$THISFILE}

. $THISDIR/../os/repo.env

for x in $@; do

  CONTAINER="$x"
  lxc-create --name $CONTAINER -B btrfs --template oracle -- --url $REPO -R 6.latest -r "perl sudo unzip oracle-rdbms-server-12cR1-preinstall"

  btrfs subvolume list /u01 >/dev/null
  if [ $? -eq 0 ]; then
    btrfs subvolume create /u01/$CONTAINER
  else
    mkdir -p /u01/$CONTAINER 
  fi
  mkdir -p /u02/$CONTAINER /u03/$CONTAINER
  mkdir -p /container/$CONTAINER/rootfs/u01 
  mkdir -p /container/$CONTAINER/rootfs/u01/stage 
  mkdir -p /container/$CONTAINER/rootfs/u02 
  mkdir -p /container/$CONTAINER/rootfs/u03
  mkdir -p /container/$CONTAINER/rootfs$THISDIR

  cat >> /container/$CONTAINER/config << EOF
lxc.mount.entry=/u03/$CONTAINER /container/$CONTAINER/rootfs/u03 none rw,bind 0 0
lxc.mount.entry=/u02/$CONTAINER /container/$CONTAINER/rootfs/u02 none rw,bind 0 0
lxc.mount.entry=/u01/$CONTAINER /container/$CONTAINER/rootfs/u01 none rw,bind 0 0
lxc.mount.entry=$THISDIR /container/$CONTAINER/rootfs$THISDIR none rw,bind 0 0
EOF

done


