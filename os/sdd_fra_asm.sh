#!/bin/bash

THISFILE=$(basename "${0}")
THISDIR=${0%$THISFILE}
BASEDIR=${0%os/$THISFILE}

id grid 2>/dev/null
if [ $? -ne 0 ]; then
  echo "user grid is required"
  echo "executing $BASEDIR/os/grid_oracle_users.sh"
  sh  "$BASEDIR/os/grid_oracle_users.sh"
fi

#install required packages
yum install -y oracleasm-support.x86_64 parted.x86_64

#configure oracleasm
if [ -d /dev/oracleasm/disks ]; then
  echo "oracleasm configured"
else
  service oracleasm configure << EOF
  grid
  asmadmin
  y
  y
EOF

fi

blkid /dev/sdd*
if [ $? -ne 0 ]; then
   if [ -b /dev/sdd1 ]; then
     echo "ignoring sdd, partition found on /dev/sdd"
   else
     echo "ok: no partition on /dev/sdd"
     parted -s /dev/sdd mklabel msdos
     parted -s /dev/sdd unit MB mkpart primary 0% 100%
   fi
   if [ -b /dev/oracleasm/disks/fra ]; then
     echo "ignoring /dev/oracleasm/disks/fra already exists"
   else
     service oracleasm createdisk fra /dev/sdd1
   fi
else
  echo "filesystem metadata found on sdd, ignoring"
fi

