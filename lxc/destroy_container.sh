for x in $@; do

  CONTAINER="$x"
  lxc-stop --name $CONTAINER
  lxc-destroy --name $CONTAINER

  btrfs su delete /container/$CONTAINER/rootfs
  btrfs su delete /u01/$CONTAINER
  \rm -r /container/$CONTAINER
  \rm -r /u01/$CONTAINER /u02/$CONTAINER /u03/$CONTAINER

done

