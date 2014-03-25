#pre req
yum install -y glibc-devel.i686

if [ -d /u01/app/*/grid/bin/ ] ; then
  echo ""
  echo "grid/bin found, skipping installation"
  echo ""
else

  #install grid
  ORACLE_BASE=/u01/app/grid
  ORACLE_HOME=/u01/app/11.2.0.3/grid

  mkdir -p $ORACLE_BASE $ORACLE_HOME
  chown -R grid:oinstall $ORACLE_BASE $ORACLE_HOME

  if [ -f /u01/stage/em/grid/runInstaller ] ; then
    sudo -H -E -u grid /u01/stage/em/grid/runInstaller -silent -ignoreSysPrereqs -ignorePrereq -force -waitforcompletion \
    ORACLE_HOSTNAME=$HOSTNAME INVENTORY_LOCATION=/u01/app/oraInventory SELECTED_LANGUAGES=en \
    oracle.install.option=CRS_SWONLY ORACLE_BASE=$ORACLE_BASE ORACLE_HOME=$ORACLE_HOME \
    oracle.install.asm.OSDBA=asmdba oracle.install.asm.OSOPER=asmoper oracle.install.asm.OSASM=asmadmin 

    /u01/app/oraInventory/orainstRoot.sh 
    /u01/app/11.2.0.3/grid/root.sh

    /u01/app/11.2.0.3/grid/perl/bin/perl -I/u01/app/11.2.0.3/grid/perl/lib -I/u01/app/11.2.0.3/grid/crs/install /u01/app/11.2.0.3/grid/crs/install/roothas.pl 

    #configuring listener
    sudo -H -E -u grid $ORACLE_HOME/bin/netca -silent -responsefile $ORACLE_HOME/assistants/netca/netca.rsp
  fi
fi
 
if [ -d /u01/app/oracle/product/11.2.0.3/dbhome_1/bin ]; then
  echo "/u01/app/oracle/product/11.2.0.3/dbhome_1/bin found, skipping db installation"
  echo ""
else
  ORACLE_BASE=/u01/app/oracle
  ORACLE_HOME=/u01/app/oracle/product/11.2.0.3/dbhome_1

  
  mkdir -p $ORACLE_BASE $ORACLE_HOME
  chown -R oracle:oinstall $ORACLE_BASE $ORACLE_HOME

  sudo -H -E -u oracle /u01/stage/em/database/runInstaller -silent -ignorePrereq -force -waitforcompletion ORACLE_HOSTNAME=$HOSTNAME \
  oracle.install.option=INSTALL_DB_SWONLY UNIX_GROUP_NAME=oinstall INVENTORY_LOCATION=/u01/app/oraInventory SELECTED_LANGUAGES=en \
  ORACLE_HOME=/u01/app/oracle/product/11.2.0.3/dbhome_1 ORACLE_BASE=/u01/app/oracle oracle.install.db.InstallEdition=EE \
  oracle.install.db.DBA_GROUP=dba DECLINE_SECURITY_UPDATES=true 

  /u01/app/oracle/product/11.2.0.3/dbhome_1/root.sh 
fi

if [ -f /u01/app/oracle/product/11.2.0.3/dbhome_1/assistants/dbca/templates/11.2.0.3_Database_Template_for_EM12_1_0_3_Small_deployment.dbc ]; then
  echo "11.2.0.3_Database_Template_for_EM12_1_0_3_Small_deployment.dbc found, skipping templates installation"
  echo ""
else
  sudo -H -E -u oracle unzip -o -d /u01/app/oracle/product/11.2.0.3/dbhome_1/assistants/dbca/templates/ /u01/stage/em/11.2.0.3_Database_Template_for_EM12_1_0_3_Linux_x64.zip 
fi

mkdir -p /u02/oradata /u03/fra
chown -R oracle: /u02/oradata/ /u03/fra/ 

ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/11.2.0.3/dbhome_1
ORACLE_SID=emrepo

[ -f /u01/app/11*/grid/bin/srvctl ] && OPTS="-d"
[ -f /u01/app/12*/grid/bin/srvctl ] && OPTS="-db"

/u01/app/1*/grid/bin/srvctl config database $OPTS $ORACLE_SID
if [ $? -eq 0 ];then
  echo "database $ORACLE_SID configured"
else
  echo "database $ORACLE_SID not configured"
  sudo -H -E -u oracle /u01/app/oracle/product/11.2.0.3/dbhome_1/bin/dbca -silent -createDatabase \
  -templateName 11.2.0.3_Database_Template_for_EM12_1_0_3_Small_deployment.dbc \
  -gdbName emrepo -sid $ORACLE_SID -sysPassword Password1 -systemPassword Password1 -emConfiguration NONE \
  -datafileDestination /u02/oradata -recoveryAreaDestination /u03/fra -storageType FS \
  -memoryPercentage 30
fi

unset ORACLE_BASE
unset ORACLE_HOME
unset ORACLE_SID

if [ -f /u01/app/oracle/product/12.1.0.3/mw ]; then
  echo "/u01/app/oracle/product/12.1.0.3/mw found, skipping installation"
  echo ""
else
  mkdir -p /u01/app/oracle/product/12.1.0.3/
  chown oracle: /u01/app/oracle/product/12.1.0.3/
  cat > /u01/stage/em/em.rsp << EOF
  RESPONSEFILE_VERSION=2.2.1.0.0 
  UNIX_GROUP_NAME=oinstall 
  INVENTORY_LOCATION=/u01/app/oraInventory 
  SECURITY_UPDATES_VIA_MYORACLESUPPORT=false 
  DECLINE_SECURITY_UPDATES=true 
  INSTALL_UPDATES_SELECTION="skip" 
  ORACLE_MIDDLEWARE_HOME_LOCATION=/u01/app/oracle/product/12.1.0.3/mw 
  ORACLE_HOSTNAME=$HOSTNAME 
  AGENT_BASE_DIR=/u01/app/oracle/product/12.1.0.3/agent 
  WLS_ADMIN_SERVER_USERNAME=weblogic 
  WLS_ADMIN_SERVER_PASSWORD=Password1 
  WLS_ADMIN_SERVER_CONFIRM_PASSWORD=Password1 
  NODE_MANAGER_PASSWORD=Password1 
  NODE_MANAGER_CONFIRM_PASSWORD=Password1 
  ORACLE_INSTANCE_HOME_LOCATION=/u01/app/oracle/product/12.1.0.3/gc_inst 
  CONFIGURE_ORACLE_SOFTWARE_LIBRARY=true 
  SOFTWARE_LIBRARY_LOCATION=/u01/app/oracle/product/12.1.0.3/swlib 
  DATABASE_HOSTNAME=$HOSTNAME 
  LISTENER_PORT=1521 
  SERVICENAME_OR_SID=emrepo 
  SYS_PASSWORD=Password1 
  SYSMAN_PASSWORD=Password1 
  SYSMAN_CONFIRM_PASSWORD=Password1 
  DEPLOYMENT_SIZE="SMALL" 
  AGENT_REGISTRATION_PASSWORD=Password1 
  AGENT_REGISTRATION_CONFIRM_PASSWORD=Password1 
  FROM_LOCATION="../oms/Disk1/stage/products.xml" 
  DEINSTALL_LIST={"oracle.sysman.top.oms","12.1.0.3.0"} 
  b_upgrade=false 
  EM_INSTALL_TYPE="NOSEED" 
  CONFIGURATION_TYPE="ADVANCED" 
  TOPLEVEL_COMPONENT={"oracle.sysman.top.oms","12.1.0.3.0"}
EOF
  sudo -H -E -u oracle /u01/stage/em/em/runInstaller -silent -waitforcompletion -responsefile /u01/stage/em/em.rsp
  /u01/app/oracle/product/12.1.0.3/mw/oms/allroot.sh

fi
