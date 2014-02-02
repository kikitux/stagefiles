#!/bin/bash

THISFILE=$(basename "${0}")
THISDIR=${0%$THISFILE}

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
                        mkdir -p $l_path
                        chown grid:oinstall $l_path
                        chmod ug+r $l_path
                        sudo -H -E -u grid mkdir -p $l_path/$patch
                        if [ -f $l_path/p$patch\_*_Linux-x86-64.zip ]; then
                          sudo -H -E -u grid unzip -o $l_path/p$patch\_*_Linux-x86-64.zip -d $l_path/$patch 2> $l_path/$patch/unzip.err > $l_path/$patch/unzip.log
                        elif [ -f $THISDIR/zip/p$patch\_*_Linux-x86-64.zip ]; then
                          sudo -H -E -u grid unzip -o $THISDIR/zip/p$patch\_*_Linux-x86-64.zip -d $l_path/$patch 2> $l_path/$patch/unzip.err > $l_path/$patch/unzip.log
                        else
			  echo "zip file for patch $patch not found" 
			fi
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

install_rac_grid_12101(){
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
  if [ ! -f ~grid/.ssh/id_rsa.pub ] && [ ! -f ~grid/.ssh/authorized_hosts ]; then
    expect /u01/stage/sshUserSetup.expect root root
    sudo -H -E -u grid expect /u01/stage/sshUserSetup.expect grid grid
  fi
  sudo -H -E -u grid /u01/stage/grid/runInstaller -silent -waitforcompletion -responseFile /u01/stage/rac_grid.rsp

fi

ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/12.1.0.1/grid
GI_HOME=/u01/app/12.1.0.1/grid

/u01/app/oraInventory/orainstRoot.sh
ssh node2 /u01/app/oraInventory/orainstRoot.sh
/u01/app/12.1.0.1/grid/root.sh
ssh node2 /u01/app/12.1.0.1/grid/root.sh

sudo -H -E -u grid /u01/app/12.1.0.1/grid/cfgtoollogs/configToolAllCommands RESPONSE_FILE=/u01/stage/configtoolallcommands.rsp
sudo -H -E -u grid /u01/app/12.1.0.1/grid/bin/asmca -silent -createDiskGroup -diskGroupName FRA -disk /dev/oracleasm/disks/FRA -redundancy EXTERNAL -sysAsmPassword Password1

sudo -H -E -u grid unzip -o /u01/stage/p6880880_121010_Linux-x86-64.zip -x PatchSearch.xml -d /u01/app/12.1.0.1/grid
ssh node2 mkdir -p /u01/stage
scp /u01/stage/p6880880_121010_Linux-x86-64.zip node2:/u01/stage
sudo -H -E -u grid ssh node2 unzip -o /u01/stage/p6880880_121010_Linux-x86-64.zip -x PatchSearch.xml -d /u01/app/12.1.0.1/grid

unzip_patch 17735306
ssh node2 sh $THISDIR/install_crs_db.sh unzip_patch 17735306

ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/12.1.0.1/grid
GI_HOME=/u01/app/12.1.0.1/grid

#Grid patch
scp /u01/stage/ocm.rsp node2:/u01/stage/ocm.rsp

$GI_HOME/OPatch/opatchauto apply /u01/stage/17735306/17735306 -oh $ORACLE_HOME -ocmrf /u01/stage/ocm.rsp
ssh node2 $GI_HOME/OPatch/opatchauto apply /u01/stage/17735306/17735306 -oh $ORACLE_HOME -ocmrf /u01/stage/ocm.rsp

ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1

if [ -d $ORACLE_HOME/bin ]; then
  echo "$ORACLE_HOME/bin found, skipping installation of database"
else
  if [ ! -f ~oracle/.ssh/id_rsa.pub ] && [ ! -f ~oracle/.ssh/authorized_hosts ]; then
    sudo -H -E -u oracle expect /u01/stage/sshUserSetup.expect oracle oracle
  fi
  sudo -H -E -u oracle /u01/stage/database/runInstaller -silent -ignorePrereq -force -waitforcompletion ORACLE_HOSTNAME=$HOSTNAME oracle.install.option=INSTALL_DB_SWONLY UNIX_GROUP_NAME=oinstall INVENTORY_LOCATION=/u01/app/oraInventory SELECTED_LANGUAGES=en ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1 ORACLE_BASE=/u01/app/oracle oracle.install.db.InstallEdition=EE oracle.install.db.DBA_GROUP=dba oracle.install.db.BACKUPDBA_GROUP=dba oracle.install.db.DGDBA_GROUP=dba oracle.install.db.KMDBA_GROUP=dba DECLINE_SECURITY_UPDATES=true oracle.install.db.CLUSTER_NODES=node1,node2

  /u01/app/oracle/product/12.1.0.1/dbhome_1/root.sh
  ssh node2 /u01/app/oracle/product/12.1.0.1/dbhome_1/root.sh
 
  sudo -H -E -u oracle unzip -o /u01/stage/p6880880_121010_Linux-x86-64.zip -x PatchSearch.xml -d /u01/app/12.1.0.1/grid
  ssh node2 mkdir -p /u01/stage
  scp /u01/stage/p6880880_121010_Linux-x86-64.zip node2:/u01/stage
  sudo -H -E -u oracle ssh node2 unzip -o /u01/stage/p6880880_121010_Linux-x86-64.zip -x PatchSearch.xml -d /u01/app/12.1.0.1/grid

  sudo -H -E -u oracle /u01/app/oracle/product/12.1.0.1/dbhome_1/OPatch/opatch apply /u01/stage/17735306/17735306/17552800 -silent -ocmrf /u01/stage/ocm.rsp

  sudo -H -E -u oracle mkdir -p /home/oracle/bin     
  sudo -H -E -u oracle ssh node2 mkdir -p /home/oracle/bin     

  echo "well done, oracle grid and database installed"
  echo "system ready to create a database"

fi


}

opatch_grid_12101(){

#OPATCH
if [ -f /u01/stage/p6880880_121010_Linux-x86-64.zip ]; then
  echo "unzipping p6880880_121010_Linux-x86-64.zip on grid"
  sudo -H -E -u grid unzip -o /u01/stage/p6880880_121010_Linux-x86-64.zip -x PatchSearch.xml -d /u01/app/12.1.0.1/grid > /dev/null
fi

#PATCH
unzip_patch 17735306

ORACLE_BASE=/u01/app/grid
ORACLE_HOME=/u01/app/12.1.0.1/grid
GI_HOME=/u01/app/12.1.0.1/grid

#Grid patch
$GI_HOME/OPatch/opatchauto apply /u01/stage/17735306/17735306 -oh $ORACLE_HOME -ocmrf /u01/stage/ocm.rsp

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
unzip_patch 17735306

GI_HOME=/u01/app/12.1.0.1/grid
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1

#Grid patch
$ORACLE_HOME/OPatch/opatchauto apply /u01/stage/17735306/17735306 -oh $ORACLE_HOME -ocmrf /u01/stage/ocm.rsp


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
  install_rac_grid_12101
  #delete_stagegrid_12101
elif [ $OPS == "unzip_patch" ];then
  unzip_patch $2
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

#if we are inside an LXC container, then we need to fix mtab
if [ -c /dev/lxc/console ]; then
  #set mtab as before
  [ -f /etc/mtab.ori ] && \mv /etc/mtab.ori /etc/mtab
fi
