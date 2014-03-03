for x in $@; do

  CONTAINER="$x"
  lxc-stop --name $CONTAINER
  lxc-destroy --name $CONTAINER

  btrfs su delete /container/$CONTAINER/rootfs 2>/dev/null
  btrfs su delete /u01/$CONTAINER 2>/dev/null
  \rm -r /container/$CONTAINER 2>/dev/null
  \rm -r /u01/$CONTAINER /u02/$CONTAINER /u03/$CONTAINER 2>/dev/null

done

