#/bin/bash
RMAN='/u01/app/oracle/product/11.2.0.3/dbhome_1/bin/rman'
FILE="${0%.sh}"
DATE=$(date +%Y%m%d%H%M)
export ORACLE_HOME='/u01/app/oracle/product/11.2.0.3/dbhome_1'

if [ $1 ] ; then
  for ORACLE_SID in $@; do 
      export ORACLE_SID
      mkdir -p /u02/bkp/$ORACLE_SID/{archivelog,backupset,controlfile,datafiles}
      $RMAN cmdfile=$FILE.rcv $ORACLE_SID $LEVEL log=$FILE.$ORACLE_SID.log append
  done
else 
  echo "use $0 <oracle_sid> <oracle_sid> "
fi
