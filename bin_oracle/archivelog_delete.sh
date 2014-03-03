#/bin/bash
FILE="${0%.sh}"
DATE=$(date +%Y%m%d%H%M)

PATH=/usr/local/bin:$PATH

if [ $1 ] ; then
  for ORACLE_SID in $@ ; do
      echo "ORACLE_SID = ${ORACLE_SID}"
      ORAENV_ASK=NO
      . oraenv
      echo "ORACLE_HOME = ${ORACLE_HOME}"
      rman cmdfile=$FILE.rcv $SID log=$FILE.$ORACLE_SID.log append
  done
else 
  echo "use $0 <oracle_sid> <oracle_sid> "
fi
