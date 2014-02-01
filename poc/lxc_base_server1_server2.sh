THISFILE=$(basename "${0}")
THISDIR=${0%$THISFILE}
BASEDIR=${0%poc/$THISFILE}


sh $BASEDIR/step.sh sh $BASEDIR/os/set_repo.sh
sh $BASEDIR/step.sh sh $BASEDIR/os/sdb_u01_btrfs.sh
sh $BASEDIR/step.sh sh $BASEDIR/os/sdc_u02_ocfs2.sh
sh $BASEDIR/step.sh sh $BASEDIR/os/sdd_u03_ocfs2.sh
sh $BASEDIR/step.sh sh $BASEDIR/lxc/install_lxc.sh
sh $BASEDIR/step.sh sh $BASEDIR/lxc/create_container.sh base
sh $BASEDIR/step.sh lxc-start --name base -d
sh $BASEDIR/step.sh sleep 15
lxc-attach --name base sh $BASEDIR/step.sh sh $BASEDIR/os/grid_oracle_user.sh
lxc-attach --name base sh $BASEDIR/step.sh sh $BASEDIR/db/preinstall_crs_db.sh
lxc-attach --name base sh $BASEDIR/step.sh sh $BASEDIR/db/unzip.sh
lxc-attach --name base sh $BASEDIR/step.sh sh $BASEDIR/db/install_crs_db.sh noroot
sh $BASEDIR/step.sh lxc-stop --name base
sh $BASEDIR/step.sh sh $BASEDIR/lxc/clone_container.sh base server1
sh $BASEDIR/step.sh lxc-start --name server1 -d
sh $BASEDIR/step.sh sleep 15
lxc-attach --name server1 sh $BASEDIR/step.sh sh $BASEDIR/db/install_crs_db.sh root
lxc-attach --name server1 sh $BASEDIR/step.sh sh $BASEDIR/db/create_db_ocfs2.sh
sh $BASEDIR/step.sh sh $BASEDIR/lxc/clone_container.sh base server2
sh $BASEDIR/step.sh sh $BASEDIR/lxc/clone_db.sh server1 server2
sh $BASEDIR/step.sh lxc-attach --name server1 poweroff
sh $BASEDIR/step.sh lxc-start --name server2 -d
sh $BASEDIR/step.sh sleep 15
lxc-attach --name server2 sh $BASEDIR/step.sh sh $BASEDIR/db/install_crs_db.sh root
lxc-attach --name server2 sh $BASEDIR/step.sh sh $BASEDIR/db/restore_db_from_disk.sh
lxc-attach --name server2 sh $BASEDIR/step.sh poweroff
sh $BASEDIR/step.sh lxc-ls
