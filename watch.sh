#!/bin/bash

mount -t btrfs ; mount -t ocfs2
echo " "
echo "/"
btrfs subvolume show / 2>/dev/null | grep -A6 Snapshot
echo " "
[ -d /container/base/rootfs ] && echo "/container/base/rootfs"
[ -d /container/base/rootfs ] && btrfs subvolume show /container/base/rootfs 2>/dev/null | grep -A6 Snapshot
echo " "
[ -d /u01/base ] && echo "/u01/base"
[ -d /u01/base ] && btrfs subvolume show /u01/base/ 2>/dev/null | grep -A6 Snapshot
echo " "
df -Ph / /u01 /u02 /u03 2>/dev/null
echo " "
du -sh /container/base/ 2>/dev/null
du -sh /u01/base/app/ 2>/dev/null
du -sh /u01/base/stage/ 2>/dev/null
echo " "
du -sh /container/server1/ 2>/dev/null
du -sh /u01/server1/app/ 2>/dev/null
du -sh /u01/server1/stage/ 2>/dev/null
du -sh /u02/server1/ 2>/dev/null
du -sh /u03/server1/ 2>/dev/null
echo " "
du -sh /container/server2/ 2>/dev/null
du -sh /u01/server2/app/ 2>/dev/null
du -sh /u01/server2/stage/ 2>/dev/null
du -sh /u02/server2/ 2>/dev/null
du -sh /u03/server2/ 2>/dev/null
echo " "
#find /u02/server1/ /u03/server1/ 2>/dev/null| egrep -v 'server[1-2]/$|u0[1-3]$|lost\+found|base|oradata$|db$|dbcopy$|fast_recovery_area$|DB$|datafiles$|backupset$|archivelog|controlfile$|onlinelog'
find /u02/server2/ /u03/server2/ 2>/dev/null| egrep -v 'server[1-2]/$|u0[1-3]$|lost\+found|base|oradata$|db$|dbcopy$|fast_recovery_area$|DB$|datafiles$|backupset$|archivelog$|controlfile$|onlinelog'
