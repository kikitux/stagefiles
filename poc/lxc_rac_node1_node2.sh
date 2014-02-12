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
[ -d /container/server1 ] && exit 1 || sh $BASEDIR/step.sh sh $BASEDIR/lxc/clone_container.sh base server1
sh $BASEDIR/step.sh lxc-start --name server1 -d
[ -d /container/server2 ] && exit 1 || sh $BASEDIR/step.sh sh $BASEDIR/lxc/clone_container.sh base server2
sh $BASEDIR/step.sh lxc-start --name server2 -d
sh $BASEDIR/step.sh sleep 15
sh $BASEDIR/step.sh lxc-ls
