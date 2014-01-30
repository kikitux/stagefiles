ORACLE_BASE=/u01/app/oracle
ORACLE_SID="db"

ORAENV_ASK=NO

PATH=/usr/local/bin:$PATH

. oraenv

$ORACLE_HOME/bin/srvctl config database -db db
if [ $? -eq 0 ];then
  echo "database $ORACLE_SID configured"
else
  echo "database $ORACLE_SID not configured"
  exit 1
fi

STATUSDB=$($ORACLE_HOME/bin/srvctl status database -d $ORACLE_SID)

if [ "${STATUSDB}" == "Database is running." ];then
  echo $ORACLE_SID is running
  mkdir -p /u03/dbcopy/$ORACLE_SID
  mkdir -p /u03/dbcopy/$ORACLE_SID/datafiles /u03/dbcopy/$ORACLE_SID/controlfile 
  mkdir -p /u03/dbcopy/$ORACLE_SID/backupset /u03/dbcopy/$ORACLE_SID/archivelog
  cat > /u03/dbcopy/$ORACLE_SID/dbcopy.rcv << EOF
connect target /
sql 'alter system archive log current' ;
run {
 set nocfau;
 configure device type disk parallelism 3 ;
 allocate channel ch1 device type disk format '/u03/dbcopy/&1/datafiles/%b';
 allocate channel ch2 device type disk format '/u03/dbcopy/&1/datafiles/%b';
 allocate channel ch3 device type disk format '/u03/dbcopy/&1/datafiles/%b';
 catalog start with '/u03/dbcopy/&1/datafiles/' noprompt ;
 crosscheck copy;
 delete noprompt expired copy;
 crosscheck backup;
 delete noprompt expired backup;
 backup as compressed backupset incremental level 1 
   for recover of copy with tag 'dbcopy_update' database reuse filesperset=5
   format '/u03/dbcopy/&1/backupset/bkp_%U';
 recover copy of database with tag 'dbcopy_update' until time 'SYSDATE';
 DELETE NOPROMPT BACKUP of database TAG='dbcopy_update' COMPLETED BEFORE 'SYSDATE';
 sql 'alter system archive log current' ;
 backup as copy archivelog from time = 'sysdate - 21/1200' until time = 'sysdate' format '/u03/dbcopy/&1/archivelog/arc_%e_%h_%s';
 backup as copy current controlfile format '/u03/dbcopy/&1/controlfile/CTL_%d_%s' tag 'dbcopy_update';
 change archivelog like '/u03/dbcopy/db/archivelog/%' uncatalog ;
 change datafilecopy tag 'DBCOPY_UPDATE' uncatalog ;
 change controlfilecopy tag 'DBCOPY_UPDATE' uncatalog ;
}
EOF
cp /u01/app/oracle/product/12.1.0.1/dbhome_1/dbs/spfile$ORACLE_SID.ora /u03/dbcopy/$ORACLE_SID/
cp /u01/app/oracle/product/12.1.0.1/dbhome_1/dbs/orapw$ORACLE_SID /u03/dbcopy/$ORACLE_SID/
chown -R oracle:oinstall /u03/dbcopy/$ORACLE_SID

sudo -H -E -u oracle $ORACLE_HOME/bin/rman cmdfile=/u03/dbcopy/$ORACLE_SID/dbcopy.rcv $ORACLE_SID
RETURN=$?
elif [ "${STATUSDB}" == "Database is not running." ];then
  echo $ORACLE_SID is not running
fi
