#!/bin/bash
THISFILE=$(basename "${0}")
THISDIR=${0%$THISFILE}

#unzip the files

if [ -d /u01 ]; then
  echo "/u01 found"
else
  echo "/u01 directory not found"
  echo "please ensure /u01 exists"
  exit 1
fi

mkdir -p /u01/stage
cd /u01/stage

if [ -d $THISDIR/zip ]; then
  if [ -f /u01/stage/grid/runInstaller -a -f /u01/stage/database/runInstaller ]; then
    echo "found grid/runInstaller and database/runInstaller"
  else
    #verify all the files are there
    for x in $(cat $THISDIR/zip/required_files.txt); do
      if [ -f $THISDIR/zip/$x ]; then
        echo "OK: $THISDIR/zip/$x found"
      else
        echo "ERROR: $THISDIR/zip/$x missed"
        exit 1
      fi
    done
    #unzip the files  
    for x in $THISDIR/zip/linuxamd64*.zip; do
      echo "unzipping $x"
      unzip -o $x >> /dev/null
    done
  fi
  \cp $THISDIR/*{.sh,.sql,.rsp,.expect} /u01/stage
  \cp -ar $THISDIR/../bin_oracle /u01/stage
  [ -f /u01/stage/p6880880_121010_Linux-x86-64.zip ] || \cp $THISDIR/zip/p6880880_121010_Linux-x86-64.zip /u01/stage
  [ -f /u01/stage/p17735306_121010_Linux-x86-64.zip ] || \cp $THISDIR/zip/p17735306_121010_Linux-x86-64.zip /u01/stage
  chown -R grid: /u01/stage/
  chmod -R ug+r /u01/stage/
else
  echo "nothing to unzip"
fi

