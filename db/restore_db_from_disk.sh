export ORACLE_SID=db
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.1/dbhome_1

$ORACLE_HOME/bin/srvctl config database -db $ORACLE_SID
if [ $? -eq 0 ];then
  echo "database $ORACLE_SID configured"
  exit 1
else
  echo "database $ORACLE_SID not configured"
fi

mkdir -p mkdir -p /u01/app/oracle/admin/db/adump /u02/oradata/db /u03/fast_recovery_area/db

\cp /u03/dbcopy/db/orapwdb /u03/dbcopy/db/spfiledb.ora $ORACLE_HOME/dbs

chown -R oracle:oinstall /u01/app/oracle/admin/ /u02/oradata/ /u03/fast_recovery_area/ /u03/dbcopy/
chown -R oracle:oinstall $ORACLE_HOME/dbs

CONTROLFILE=$(ls -trc /u03/dbcopy/db/controlfile/ | tail -n1)

cat > /u03/dbcopy/db/restore.rcv << EOF
startup nomount
restore controlfile from "/u03/dbcopy/db/controlfile/$CONTROLFILE";
alter database mount;
change archivelog like '/u03/dbcopy/db/archivelog/%' uncatalog ;
change datafilecopy tag 'DBCOPY_UPDATE' uncatalog ;
crosscheck copy;
catalog start with '/u03/dbcopy/db/datafiles/' noprompt ;
catalog start with '/u03/dbcopy/db/archivelog/' noprompt ;

restore database;
recover database;

EOF

cat > /u03/dbcopy/db/openresetlogs.rcv << EOF

alter database open resetlogs;
shutdown immediate;

EOF

sudo -H -E -u oracle $ORACLE_HOME/bin/rman target / cmdfile=/u03/dbcopy/db/restore.rcv
sudo -H -E -u oracle $ORACLE_HOME/bin/rman target / cmdfile=/u03/dbcopy/db/openresetlogs.rcv
if [ $? -eq 0 ];then
  sudo -H -E -u oracle $ORACLE_HOME/bin/srvctl add database -db $ORACLE_SID -oraclehome $ORACLE_HOME
  sudo -H -E -u oracle $ORACLE_HOME/bin/srvctl start database -db $ORACLE_SID
  sudo -H -E -u oracle $ORACLE_HOME/bin/srvctl status database -db $ORACLE_SID
fi

STATUSDB=$($ORACLE_HOME/bin/srvctl status database -d $ORACLE_SID)
if [ "${STATUSDB}" == "Database is running." ];then
  echo "database $ORACLE_SID is running"
else
  echo "database $ORACLE_SID is not running"
  exit 1
fi
