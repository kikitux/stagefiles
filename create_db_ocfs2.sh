ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1

CONTAINER_OPS="-createAsContainerDatabase false"
TEMPLATE="General_Purpose.dbc"
ORACLE_SID="db"
HOSTNAME=$(hostname -s)
sysPassword="Password1"
systemPassword="Password1"
dbsnmpPassword="Password1"
datafileDestination="/u02/oradata"
recoveryAreaDestination="/u03/fast_recovery_area"
redoLogFileSize="500"
totalMemory="2048"

#if we are inside an LXC container, then we need to fix mtab
if [ -c /dev/lxc/console ]; then
  cp /etc/mtab /etc/mtab.ori
  grep -v "^[! ]* / tmpfs " /proc/mounts | grep -v devpts > /etc/mtab
fi

$ORACLE_HOME/bin/srvctl status database -d $ORACLE_SID 2>&1 > /dev/null
if [ $? = 0 ] ; then
  echo "db $ORACLE_SID already exists"
  sleep 2
else
  mkdir -p $datafileDestination $recoveryAreaDestination
  chown oracle:oinstall $datafileDestination $recoveryAreaDestination
  sudo -H -E -u oracle $ORACLE_HOME/bin/dbca -silent -createDatabase $CONTAINER_OPS -templateName $TEMPLATE -gdbname $ORACLE_SID.$HOSTNAME -sid $ORACLE_SID -datafileJarLocation $ORACLE_HOME/assistants/dbca/templates -responseFile NO_VALUE -memoryPercentage 30 -emConfiguration DBEXPRESS -dbsnmpPassword $dbsnmpPassword -storageType FS -datafileDestination $datafileDestination -recoveryAreaDestination $recoveryAreaDestination -redoLogFileSize $redoLogFileSize -sysPassword $sysPassword -systemPassword $systemPassword -totalMemory $totalMemory 2>&1 | tee -a /u01/stage/setup.db.$ORACLE_SID.log
  sudo -u oracle sh -c "ORAENV_ASK=NO; ORACLE_SID=$ORACLE_SID; PATH=/usr/local/bin:$PATH;  . oraenv ; sqlplus / as sysdba @/u01/stage/enable_archivelog"
fi

[ -f /etc/mtab.ori ] && \mv /etc/mtab.ori /etc/mtab
