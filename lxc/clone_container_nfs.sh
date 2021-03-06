THISFILE=$(basename "${0}")
THISDIR=${0%$THISFILE}
BASEDIR=${0%lxc/$THISFILE}

if [ $# -lt 2 ];then
  echo "this command requires 2 arguments, source destination"
  exit 1
fi

CONTAINER1="$1"
CONTAINER2="$2"

lxc-clone -s -t btrfs -o $CONTAINER1 -n $CONTAINER2
if [ $? -eq 0 ];then
  echo "lxc-clone success"
else
  echo "lxc-clone failed"
  exit 1
fi

echo "if on btrfs, we will do a snapshot of /u01/base"
echo "if fails, will use rsync"

if [ -d /u01/$CONTAINER2 ]; then
  echo "destination /u01/$CONTAINER2 already exits, exiting.."
  exit 1
fi

btrfs su snapshot /u01/$CONTAINER1 /u01/$CONTAINER2 && echo OK || rsync -PavzHl /u01/$CONTAINER1/ /u01/$CONTAINER2/

mkdir -p /u02/$CONTAINER2 /u03/$CONTAINER2
mkdir -p /container/$CONTAINER2/rootfs/u01 
mkdir -p /container/$CONTAINER2/rootfs/$BASEDIR

mv /container/$CONTAINER2/config /container/$CONTAINER2/config.ori
grep -v 'lxc.mount.entry' /container/$CONTAINER2/config.ori > /container/$CONTAINER2/config
cat >> /container/$CONTAINER2/config << EOF
lxc.mount.entry=/u01/$CONTAINER2 /container/$CONTAINER2/rootfs/u01 none rw,bind 0 0
lxc.mount.entry=$BASEDIR /container/$CONTAINER2/rootfs$BASEDIR none rw,bind 0 0
EOF

grep 'u02/grid_disk' /etc/exports || echo '/u02/grid_disk *(rw,insecure,no_root_squash)' >> /etc/exports
grep 'u03/grid_disk' /etc/exports || echo '/u03/grid_disk *(rw,insecure,no_root_squash)' >> /etc/exports
chkconfig nfs on
service nfs restart

echo configuring $CONTAINER2
if [ -f /container/$CONTAINER2/config ]; then
  for i in 2 3 ; do
    grep "u0$i/grid_disk" /container/$CONTAINER2/rootfs/etc/fstab
    if [ $? -ne 0 ];then
      echo "192.168.122.1:/u0$i/grid_disk /u0$i/grid_disk nfs rw,bg,hard,nointr,rsize=32768,wsize=32768,tcp,actimeo=0,vers=3,timeo=600 0 0" >> /container/$CONTAINER2/rootfs/etc/fstab
      mkdir -p /container/$CONTAINER2/rootfs/u0$i/grid_disk /u0$i/grid_disk
    fi
  done
fi
