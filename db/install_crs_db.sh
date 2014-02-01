#!/bin/bash

unzip_patch()
{
if [ $# -lt 1 ]; then
        echo "unzip_patch require 1 or more parameter"
        echo "unzip_patch <patch_number> <patch_number> .. <patch_number>"
else
        local l_path=/u01/stage
        for patch in $@; do
                if [ -d $l_path/$patch ]; then
                        echo "Directory $l_path/$patch found, skipping"
                        echo "If you want to unzip this patch again, please remove the $l_path/$patch directory"
                else
                                sudo -H -E -u grid mkdir -p $l_path/$patch
                                sudo -H -E -u grid unzip -o $l_path/p$patch\_*_Linux-x86-64.zip -d $l_path/$patch 2> $l_path/$patch/unzip.err > $l_path/$patch/unzip.log
                                chmod -R ug+r $l_path/$patch
                fi
        done
fi
}

install_grid_12101(){
if [ -f /u01/stage/grid/runInstaller ] ; then
        echo "stage grid found .."
else
        echo " Error: /u01/stage/grid not found"
        echo " ensure all the files have been unzipped at /u01/stage level"
        exit 1
fi

ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/12.1.0.1/grid
GI_HOME=/u01/app/12.1.0.1/grid

echo "oraInventory in /u01/app/oraInventory"
echo "Oracle Base for grid is $ORACLE_BASE "
echo "Oracle Home for grid is $ORACLE_HOME "

if [ -d $ORACLE_HOME/bin ]; then
  echo "$ORACLE_HOME/bin found, skipping installation of grid"
else
  sudo -H -E -u grid /u01/stage/grid/runInstaller -silent -ignoreSysPrereqs -ignorePrereq -force -waitforcompletion ORACLE_HOSTNAME=$HOSTNAME INVENTORY_LOCATION=/u01/app/oraInventory SELECTED_LANGUAGES=en oracle.install.option=CRS_SWONLY ORACLE_BASE=$ORACLE_BASE ORACLE_HOME=$ORACLE_HOME oracle.install.asm.OSDBA=asmdba oracle.install.asm.OSOPER=asmoper oracle.install.asm.OSASM=asmadmin

  /u01/app/oraInventory/orainstRoot.sh
fi
}

root_grid_12101(){

ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/12.1.0.1/grid
GI_HOME=/u01/app/12.1.0.1/grid

$ORACLE_HOME/root.sh
$ORACLE_HOME/perl/bin/perl -I$ORACLE_HOME/perl/lib -I$ORACLE_HOME/crs/install $ORACLE_HOME/crs/install/roothas.pl

}

root_rac_grid_12101(){

ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/12.1.0.1/grid
GI_HOME=/u01/app/12.1.0.1/grid

$ORACLE_HOME/root.sh

cd $ORACLE_HOME
echo "attaching grid home to the inventory.."
sudo -H -E -u grid $ORACLE_HOME/oui/bin/attachHome.sh

}

opatch_grid_12101(){

#OPATCH
if [ -f /u01/stage/p6880880_121010_Linux-x86-64.zip ]; then
  echo "unzipping p6880880_121010_Linux-x86-64.zip on grid"
  sudo -H -E -u grid unzip -o /u01/stage/p6880880_121010_Linux-x86-64.zip -x PatchSearch.xml -d /u01/app/12.1.0.1/grid > /dev/null
fi

#PATCH
unzip_patch 17272829

ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/12.1.0.1/grid
GI_HOME=/u01/app/12.1.0.1/grid

#Grid patch
$GI_HOME/OPatch/opatchauto apply /u01/stage/17272829/17272829 -oh $ORACLE_HOME -ocmrf /u01/stage/ocm.rsp

}

configure_listener_12101(){
ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/12.1.0.1/grid
GI_HOME=/u01/app/12.1.0.1/grid

sudo -H -E -u grid $ORACLE_HOME/bin/netca -silent -responsefile $ORACLE_HOME/assistants/netca/netca.rsp
sudo -H -E -u grid $ORACLE_HOME/bin/srvctl status listener -l LISTENER

}

delete_stagegrid_12101(){
if [ -d /u01/stage/grid ]; then
  rm -fr /u01/stage/grid
fi
}

install_db_12101()
{

if [ -f /u01/stage/database/runInstaller ] ; then
        echo "stage database found .."
else
        echo " Error: /u01/stage/database not found"
        echo " ensure all the files have been unzipped at /u01/stage level"
        exit 1
fi

echo "oraInventory in /u01/app/oraInventory"
echo "Oracle Base for grid is /u01/app/grid"
echo "Oracle Home for grid is /u01/app/12.1.0.1/grid"

sudo -H -E -u oracle /u01/stage/database/runInstaller -silent -ignorePrereq -force -waitforcompletion ORACLE_HOSTNAME=$HOSTNAME oracle.install.option=INSTALL_DB_SWONLY UNIX_GROUP_NAME=oinstall INVENTORY_LOCATION=/u01/app/oraInventory SELECTED_LANGUAGES=en ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1 ORACLE_BASE=/u01/app/oracle oracle.install.db.InstallEdition=EE oracle.install.db.DBA_GROUP=dba oracle.install.db.BACKUPDBA_GROUP=dba oracle.install.db.DGDBA_GROUP=dba oracle.install.db.KMDBA_GROUP=dba DECLINE_SECURITY_UPDATES=true

sudo -H -E -u oracle mkdir -p /home/oracle/bin

}

root_db_12101()
{

ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1
$ORACLE_HOME/root.sh

}

opatch_db_12101(){

#OPATCH
if [ -f /u01/stage/p6880880_121010_Linux-x86-64.zip ]; then
  echo "unzipping p6880880_121010_Linux-x86-64.zip on db"
  sudo -H -E -u oracle unzip -o /u01/stage/p6880880_121010_Linux-x86-64.zip -x PatchSearch.xml -d /u01/app/oracle/product/12.1.0.1/dbhome_1 > /dev/null
fi

#PATCH
unzip_patch 17272829

GI_HOME=/u01/app/12.1.0.1/grid
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1

#Grid patch
$ORACLE_HOME/OPatch/opatchauto apply /u01/stage/17272829/17272829 -oh $ORACLE_HOME -ocmrf /u01/stage/ocm.rsp


}

delete_stagedb_12101(){
if [ -d /u01/stage/database ]; then
  rm -fr /u01/stage/database
fi
}

#if we are inside an LXC container, then we need to fix mtab
if [ -c /dev/lxc/console ]; then
  cp /etc/mtab /etc/mtab.ori
  grep -v "^[! ]* / tmpfs " /proc/mounts | grep -v devpts > /etc/mtab
fi

if [ $1 ]; then
  OPS=$1
else
  OPS="empty"
fi

if [ $OPS == "noroot" ];then
  install_grid_12101
  opatch_grid_12101
  install_db_12101
elif [ $OPS == "root" ];then
  root_grid_12101
  configure_listener_12101
  root_db_12101
  opatch_db_12101
elif [ $OPS == "rac" ];then
  install_grid_12101
  root_rac_grid_12101
  #delete_stagegrid_12101
  #in rac, we require the patches in same location on all nodes
  #unzip now, to ensure PSU/CPU is on both nodes
  #even when OPatch will be called from node1 later
  unzip_patch 17272829
else
  install_grid_12101
  opatch_grid_12101
  root_grid_12101
  #delete_stagegrid_12101
  configure_listener_12101
  install_db_12101
  root_db_12101
  opatch_db_12101
  #delete_stagedb_12101
fi

#set mtab as before
[ -f /etc/mtab.ori ] && \mv /etc/mtab.ori /etc/mtab
