if [ -d /pre_lxc ]; then
  for x in $@; do
  CONTAINER="$x"
  lxc-create --name $CONTAINER --template oracle -- -t /pre_lxc

  mkdir -p /u01/$CONTAINER /u02/$CONTAINER /u03/$CONTAINER
  mkdir -p /container/$CONTAINER/rootfs/u01 /container/$CONTAINER/rootfs/u01/stage /container/$CONTAINER/rootfs/u02 /container/$CONTAINER/rootfs/u03

  cat >> /container/$CONTAINER/config << EOF
lxc.mount.entry=/u02/$CONTAINER /container/$CONTAINER/rootfs/u02 none rw,bind 0 0
lxc.mount.entry=/u03/$CONTAINER /container/$CONTAINER/rootfs/u03 none rw,bind 0 0
lxc.mount.entry=/media/sf_stagefiles /container/$CONTAINER/rootfs/media/sf_stagefiles none rw,bind 0 0
EOF

done

fi
