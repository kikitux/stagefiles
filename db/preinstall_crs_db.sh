#!/bin/bash
#take care of some prerequirements

#install preinstall rpm for oracle 12c db

echo "installing oracle-rdbms-server-12cR1-preinstall"
if [ -c /dev/lxc/console ]; then
  PACKAGES="oracle-rdbms-server-12cR1-preinstall perl unzip sudo"
else
  PACKAGES="oracle-rdbms-server-12cR1-preinstall perl yum-plugin-fs-snapshot ocfs2-tools reflink btrfs-progs parted oracleasm-support unzip sudo"
fi

rpm -q $PACKAGES
if [ $? -ne 0 ]; then
  yum clean all
  yum -y install $PACKAGES 
fi

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

ARG=$1
if [ $ARG == "rac" ] ;then
  rpm -q expect 2>&1 >> /dev/null || yum install -y expect
  [ -f /media/stagefiles/os/99-oracle-asmdevices.rules ] && \cp /media/stagefiles/os/99-oracle-asmdevices.rules /etc/udev/rules.d/
  start_udev
  [ -f /media/stagefiles/db/zip/linuxamd64_12c_grid_1of2.zip ] && unzip -o /media/stagefiles/db/zip/linuxamd64_12c_grid_1of2.zip -d /u01/stage grid/rpm/cvuqdisk-1.0.9-1.rpm
  [ -f /media/stagefiles/db/zip/linuxamd64_12c_grid_1of2.zip ] && unzip -o /media/stagefiles/db/zip/linuxamd64_12c_grid_1of2.zip -d /u01/stage grid/sshsetup/sshUserSetup.sh
  yum install -y /u01/stage/grid/rpm/cvuqdisk-1.0.9-1.rpm
  RP_ETH2="net.ipv4.conf.eth2.rp_filter=2"
  RP_ETH3="net.ipv4.conf.eth3.rp_filter=2"
  grep $RP_ETH2 /etc/sysctl.conf 2>/dev/null || echo $RP_ETH2 >> /etc/sysctl.conf
  grep $RP_ETH3 /etc/sysctl.conf 2>/dev/null || echo $RP_ETH3 >> /etc/sysctl.conf
  sysctl -p
fi

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
