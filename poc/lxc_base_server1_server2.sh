THISFILE=$(basename "${0}")
THISDIR=${0%$THISFILE}

sh $THISDIR/step.sh sh $THISDIR/os/set_repo.sh
sh $THISDIR/step.sh sh $THISDIR/os/sdb_u01_btrfs.sh
sh $THISDIR/step.sh sh $THISDIR/os/sdc_u02_ocfs2.sh
sh $THISDIR/step.sh sh $THISDIR/os/sdd_u03_ocfs2.sh
sh $THISDIR/step.sh sh $THISDIR/lxc/install_lxc.sh
sh $THISDIR/step.sh sh $THISDIR/lxc/create_container.sh base
sh $THISDIR/step.sh lxc-start --name base -d
sh $THISDIR/step.sh sleep 15
lxc-attach --name base sh $THISDIR/step.sh sh $THISDIR/db/preinstall_crs_db.sh
lxc-attach --name base sh $THISDIR/step.sh sh $THISDIR/db/unzip.sh
lxc-attach --name base sh $THISDIR/step.sh sh $THISDIR/db/install_crs_db.sh noroot
sh $THISDIR/step.sh lxc-stop --name base
sh $THISDIR/step.sh sh $THISDIR/lxc/clone_container.sh base server1
sh $THISDIR/step.sh lxc-start --name server1 -d
sh $THISDIR/step.sh sleep 15
lxc-attach --name server1 sh $THISDIR/step.sh sh $THISDIR/db/install_crs_db.sh root
lxc-attach --name server1 sh $THISDIR/step.sh sh $THISDIR/db/create_db_ocfs2.sh
sh $THISDIR/step.sh sh $THISDIR/lxc/clone_container.sh base server2
sh $THISDIR/step.sh sh $THISDIR/lxc/clone_db.sh server1 server2
sh $THISDIR/step.sh lxc-attach --name server1 poweroff
sh $THISDIR/step.sh lxc-start --name server2 -d
sh $THISDIR/step.sh sleep 15
lxc-attach --name server2 sh $THISDIR/step.sh sh $THISDIR/db/install_crs_db.sh root
lxc-attach --name server2 sh $THISDIR/step.sh sh $THISDIR/db/restore_db_from_disk.sh
lxc-attach --name server2 sh $THISDIR/step.sh poweroff
sh $THISDIR/step.sh lxc-ls
