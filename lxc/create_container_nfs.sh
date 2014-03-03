#!/bin/bash

THISFILE=$(basename "${0}")
THISDIR=${0%$THISFILE}
BASEDIR=${0%lxc/$THISFILE}


[ $REPO ] || . $BASEDIR/os/repo.env

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
  mkdir -p /container/$CONTAINER/rootfs$BASEDIR

  cat >> /container/$CONTAINER/config << EOF
lxc.mount.entry=/u01/$CONTAINER /container/$CONTAINER/rootfs/u01 none rw,bind 0 0
lxc.mount.entry=$BASEDIR /container/$CONTAINER/rootfs$BASEDIR none rw,bind 0 0
EOF

done


grep 'u02/grid_disk' /etc/exports || echo '/u02/grid_disk *(rw,insecure,no_root_squash)' >> /etc/exports
grep 'u03/grid_disk' /etc/exports || echo '/u03/grid_disk *(rw,insecure,no_root_squash)' >> /etc/exports
chkconfig nfs on
service nfs restart

for x in $@ ; do
  echo configuring $x
  if [ -f /container/$x/config ]; then
    for i in 2 3 ; do
      #grep "u0$i/grid_disk" /container/$x/config
      grep "u0$i/grid_disk" /container/$x/rootfs/etc/fstab
      if [ $? -ne 0 ];then
        echo "192.168.122.1:/u0$i/grid_disk /u0$i/grid_disk nfs rw,bg,hard,nointr,rsize=32768,wsize=32768,tcp,actimeo=0,vers=3,timeo=600 0 0" >> /container/$x/rootfs/etc/fstab
        mkdir -p /container/$x/rootfs/u0$i/grid_disk /u0$i/grid_disk
      fi
    done
  fi
done
