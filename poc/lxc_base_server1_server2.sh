sh /media/sf_stagefiles/step.sh sh /media/sf_stagefiles/lxc/create_container.sh base
sh /media/sf_stagefiles/step.sh lxc-start --name base -d
sh /media/sf_stagefiles/step.sh sleep 15
lxc-attach --name base sh /media/sf_stagefiles/step.sh sh /media/sf_stagefiles/preinstall_crs_db.sh
lxc-attach --name base sh /media/sf_stagefiles/step.sh sh /media/sf_stagefiles/install_crs_db.sh noroot
sh /media/sf_stagefiles/step.sh lxc-stop --name base
sh /media/sf_stagefiles/step.sh sh /media/sf_stagefiles/lxc/clone_container.sh base server1
sh /media/sf_stagefiles/step.sh lxc-start --name server1 -d
sh /media/sf_stagefiles/step.sh sleep 15
lxc-attach --name server1 sh /media/sf_stagefiles/step.sh sh /media/sf_stagefiles/install_crs_db.sh root
lxc-attach --name server1 sh /media/sf_stagefiles/step.sh sh /media/sf_stagefiles/create_db_ocfs2.sh
sh /media/sf_stagefiles/step.sh sh /media/sf_stagefiles/lxc/clone_container.sh base server2
sh /media/sf_stagefiles/step.sh sh /media/sf_stagefiles/lxc/clone_db.sh server1 server2
sh /media/sf_stagefiles/step.sh lxc-attach --name server1 poweroff
sh /media/sf_stagefiles/step.sh lxc-start --name server2 -d
sh /media/sf_stagefiles/step.sh sleep 15
lxc-attach --name server2 sh /media/sf_stagefiles/step.sh sh /media/sf_stagefiles/install_crs_db.sh root
lxc-attach --name server2 sh /media/sf_stagefiles/step.sh sh /media/sf_stagefiles/restore_db_from_disk.sh
lxc-attach --name server2 sh /media/sf_stagefiles/step.sh poweroff
sh /media/sf_stagefiles/step.sh lxc-ls
