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

mkdir -p /u01/stage/em
cd /u01/stage/em

if [ -d $THISDIR/zip ]; then
  #verify all the files are there
  for x in $(cat $THISDIR/zip/required_files.txt); do
    if [ -f $THISDIR/zip/$x ]; then
      echo "OK: $THISDIR/zip/$x found"
    else
      echo "ERROR: $THISDIR/zip/$x missed"
      exit 1
    fi
  done
  if [ -f /u01/stage/em/grid/runInstaller ]; then
    echo "found grid/runInstaller"
  else
    #unzip the files  
    x="$THISDIR/zip/p10404530_112030_Linux-x86-64_3of7.zip"
    echo "unzipping $x"
    unzip -o $x >> /dev/null
  fi
  if [ -f /u01/stage/em/database/runInstaller ]; then
    echo "found database/runInstaller"
  else
    #unzip the files  
    for x in $THISDIR/zip/p10404530_112030_Linux-x86-64_{1,2}of7.zip; do
      echo "unzipping $x"
      unzip -o $x >> /dev/null
    done
  fi
  if [ -f /u01/stage/em/em/runInstaller ]; then
    echo "found database/runInstaller"
  else
    mkdir em
    for x in $THISDIR/zip/em12103p1_linux64_disk{1,2,3}.zip; do
      unzip -d em -o $x >> /dev/null
    done
  fi
  [ -f /u01/stage/11.2.0.3_Database_Template_for_EM12_1_0_3_Linux_x64.zip ] || \cp $THISDIR/zip/11.2.0.3_Database_Template_for_EM12_1_0_3_Linux_x64.zip /u01/stage
  if [ -d /u01/stage/em/bishiphome/ ]; then
    echo "found bishiphome"
  else
    for x in $THISDIR/zip/bi_linux_x86_111160_64_disk{{1,2}_{1,2}of2,3}.zip ; do
      echo $x
      unzip -o $x >> /dev/null
    done
  fi
  chown -R oracle: /u01/stage/em/
  chmod -R ug+r /u01/stage/em/
else
  echo "nothing to unzip"
fi

