#!/bin/bash

mount -t btrfs ; mount -t ocfs2
echo " "
df -Ph / /u01 /u02 /u03 2>/dev/null
echo " "
btrfs subvolume show / 2>/dev/null | grep -A6 Snapshot | xargs echo / 
for x in $(lxc-ls) ; do
  SNAP=$( btrfs subvolume show /container/$x/rootfs 2>/dev/null| grep -A6 Snapshot)
  SNAPCOUNT=$(echo $SNAP | wc -w)
 [ $SNAPCOUNT -gt 1 ] && echo $SNAP | grep -v yum_ | xargs echo /container/$x/rootfs
  SNAP=$( btrfs subvolume show /u01/$x 2>/dev/null| grep -A6 Snapshot)
  SNAPCOUNT=$(echo $SNAP | wc -w)
  [ $SNAPCOUNT -gt 1 ] && echo $SNAP | grep -v yum_ | xargs echo /u01/$x
  echo " "
  du -sh /container/$x/ 2>/dev/null
  du -sh /u01/$x/app/ 2>/dev/null
  du -sh /u01/$x/stage/ 2>/dev/null
  du -sh /u02/$x/ 2>/dev/null
  du -sh /u03/$x/ 2>/dev/null
done
echo " "
