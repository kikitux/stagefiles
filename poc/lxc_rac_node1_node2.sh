THISFILE=$(basename "${0}")
THISDIR=${0%$THISFILE}
BASEDIR=${0%poc/$THISFILE}


[ -d /container/base ] && echo "base container exists. reusing it" || sh $BASEDIR/step.sh sh $BASEDIR/lxc/create_container.sh base
sh $BASEDIR/step.sh lxc-start --name base -d
sh $BASEDIR/step.sh sleep 15
lxc-attach --name base sh $BASEDIR/step.sh sh $BASEDIR/os/grid_oracle_user.sh
lxc-attach --name base sh $BASEDIR/step.sh sh $BASEDIR/db/preinstall_crs_db.sh
lxc-attach --name base sh $BASEDIR/step.sh sh $BASEDIR/db/unzip.sh
sh $BASEDIR/step.sh lxc-stop --name base
[ -d /container/node1 ] && exit 1 || sh $BASEDIR/step.sh sh $BASEDIR/lxc/clone_container_nfs.sh base node1
[ -d /container/node2 ] && exit 1 || sh $BASEDIR/step.sh sh $BASEDIR/lxc/clone_container_nfs.sh base node2
sh $BASEDIR/step.sh sh $BASEDIR/poc/network.sh node1 node2
sh $BASEDIR/step.sh lxc-start --name node1 -d
sh $BASEDIR/step.sh lxc-start --name node2 -d
sh $BASEDIR/step.sh sleep 15
sh $BASEDIR/step.sh lxc-ls
