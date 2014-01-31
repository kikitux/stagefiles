THISFILE=$(basename "${0}")
THISDIR=${0%$THISFILE}

CONTAINER1=$1
CONTAINER2=$2

rpm -q reflink 2>/dev/null
if [ $? -ne 0 ]; then
  yum clean all
  yum install -y reflink
fi

lxc-attach --name $CONTAINER1 id 2>&1 > /dev/null
if [ $? -eq 0 ]; then
  lxc-attach --name $CONTAINER1 sh $THISDIR/step.sh sh $THISDIR/db/clone_db_to_disk.sh
  if [ $? -eq 0 ]; then
    #mv /u03/$CONTAINER1/dbcopy/ /u03/$CONTAINER2/dbcopy/
    cd /u03/$CONTAINER1/dbcopy/
    for dir in $(find . -type d); do
      mkdir -p /u03/$CONTAINER2/dbcopy/$dir
    done
    for file in $(find . -type f); do
      reflink /u03/$CONTAINER1/dbcopy/$file /u03/$CONTAINER2/dbcopy/$file
    done
  fi
fi

