rpm -q lxc >/dev/null
if [ $? -ne 0 ]; then
  btrfs subvolume list / >/dev/null
  if [ $? -eq 0 ]; then
    rpm -q yum-plugin-fs-snapshot 2>/dev/null || yum install -y yum-plugin-fs-snapshot
    chkconfig vboxadd off
    chkconfig vboxadd-service off
    chkconfig vboxadd-x11 off
    chkconfig ocfs2 off
    chkconfig o2cb off
    btrfs subvolume snapshot / /pre_lxc
    chkconfig vboxadd on
    chkconfig vboxadd-service on
    chkconfig vboxadd-x11 on
    chkconfig ocfs2 on
    chkconfig o2cb on
  fi
  yum install -y lxc >/dev/null
  echo "Please reboot the node after this script finish"
fi
if [ -d /container ]; then
  echo "/container exists"
else
  btrfs subvolume list / >/dev/null
  if [ $? -eq 0 ]; then
    btrfs subvolume create /container
  else
    mkdir -p /container
  fi
fi

chkconfig cgconfig on
service cgconfig restart

service libvirtd start

#set required ulimit for lxc to work
if [ -f /etc/security/limits.conf.lxc ]; then
  echo "seems this part was already executed"
else
  cp /etc/security/limits.conf /etc/security/limits.conf.lxc
  echo '*     hard  nofile  65536'>> /etc/security/limits.conf
  echo '*     soft  nofile  65000'>> /etc/security/limits.conf
fi

sysctl -w net.ipv4.ip_forward=1
sed -i -e 's/net.ipv4.ip_forward\s=\s0$/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
