#!/bin/bash
#take care of some prerequirements

#install preinstall rpm for oracle 12c db

echo "installing oracle-rdbms-server-12cR1-preinstall"
if [ -c /dev/lxc/console ]; then
  PACKAGES="oracle-rdbms-server-12cR1-preinstall perl unzip sudo"
else
  PACKAGES="oracle-rdbms-server-12cR1-preinstall perl yum-plugin-fs-snapshot ocfs2-tools reflink btrfs-progs parted oracleasm-support unzip sudo"
fi

yum clean all
yum -y install $PACKAGES 

#stop sendmail service if we are in a container
if [ -c /dev/lxc/console ]; then
  [ -f /etc/init.d/sendmail ] && chkconfig sendmail off
fi

#set required ulimit for grid user
if [ -f /etc/security/limits.conf.preinstall ]; then
  echo "seems this part was already executed"
else
  cp /etc/security/limits.conf /etc/security/limits.conf.preinstall
    if [ -c /dev/lxc/console ]; then
      echo 'grid  soft  nproc  2047'>> /etc/security/limits.conf
      mv /etc/security/limits.d/oracle-rdbms-server-12cR1-preinstall.conf /etc/security/limits.d/oracle-rdbms-server-12cR1-preinstall.conf.ori
      grep -v nofile /etc/security/limits.d/oracle-rdbms-server-12cR1-preinstall.conf.ori > /etc/security/limits.d/oracle-rdbms-server-12cR1-preinstall.conf
    else
      echo 'grid  hard  nofile  65536'>> /etc/security/limits.conf
      echo 'grid  soft  nproc  2047'>> /etc/security/limits.conf
    fi
fi

#create the extra groups for db12c role separation
echo "Checking groups for grid and oracle user"

grep ^asmdba:    /etc/group || groupadd -g 54318 asmdba
grep ^asmoper:   /etc/group || groupadd -g 54319 asmoper
grep ^asmadmin:  /etc/group || groupadd -g 54320 asmadmin
grep ^oinstall:  /etc/group || groupadd -g 54321 oinstall
grep ^dba:       /etc/group || groupadd -g 54322 dba
grep ^backupdba: /etc/group || groupadd -g 54323 backupdba
grep ^oper:      /etc/group || groupadd -g 54324 oper
grep ^dgdba:     /etc/group || groupadd -g 54325 dgdba
grep ^kmdba:     /etc/group || groupadd -g 54326 kmdba

#create or modify as required user grid and oracle
echo "verifying grid user"
id grid   > /dev/null  && usermod -a -g oinstall -G asmdba,asmadmin,asmoper,dba grid                 || useradd -u 54320 -g oinstall -G asmdba,asmadmin,asmoper,dba grid
echo "verifying oracle user"
id oracle > /dev/null  && usermod -a -g oinstall -G dba,asmdba,backupdba,oper,dgdba,kmdba oracle || useradd -u 54321 -g oinstall -G dba,asmdba,backupdba,oper,dgdba,kmdba oracle

#set initial password
echo oracle | passwd --stdin oracle
echo grid   | passwd --stdin grid

#create and set owner/permissions on path structure

if [ -d /u01 ]; then
  mkdir -p /u01/stage
  cd /u01/stage
  if [ $? -ne 0 ];then
     echo "can't change into /u01/stage. Please review and run this script again"
     exit 1
  fi
else
  echo " /u01 mount point doesn't exist. Please create and run this script again "
  exit 1
fi

mkdir -p /u01/app/grid /u01/app/oraInventory /u01/app/12.1.0.1/grid /u01/app/oracle/product/12.1.0.1/dbhome_1
chown       oracle:oinstall     /u01
chown -R    oracle:oinstall     /u01/app
chown -R    grid:oinstall       /u01/app/12.1.0.1
chown -R    grid:oinstall       /u01/app/grid
chown -R    grid:oinstall       /u01/app/oraInventory
chown -R    oracle:oinstall     /home/oracle
chown -R    grid:oinstall       /home/grid
chmod       ug+rw               /u01
chmod -R    ug+rw               /u01/app

sed -i -e 's/Defaults\s*requiretty$/#Defaults\trequiretty/' /etc/sudoers

#hostname need to be on /etc/hosts

short=$(hostname -s)
grep $short /etc/hosts >/dev/null
if [ $? -ne 0 ]; then
  cp /etc/hosts /etc/hosts.ori
  cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 $short
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

EOF

fi
