for x in $@ ; do
  echo configuring $x
  if [ -f /container/$x/config ]; then
    \mv /container/$x/config{,.ori}
    grep -v lxc.network /container/$x/config.ori > /container/$x/config

    echo 'lxc.network.type = veth'	>> /container/$x/config
    echo 'lxc.network.link = br0'	>> /container/$x/config
    echo 'lxc.network.flags = up'	>> /container/$x/config
    echo 'lxc.network.type = veth'	>> /container/$x/config
    echo 'lxc.network.link = virbr0'	>> /container/$x/config
    echo 'lxc.network.flags = up'	>> /container/$x/config
    echo 'lxc.network.type = veth'	>> /container/$x/config
    echo 'lxc.network.link = virbr0'	>> /container/$x/config
    echo 'lxc.network.flags = up'	>> /container/$x/config

    echo '' 		> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    echo 'DEVICE=eth0' 		>> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    echo 'BOOTPROTO=none' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    echo 'ONBOOT=yes' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    echo "DHCP_HOSTNAME=$x" >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    echo 'NM_CONTROLLED=no' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    echo 'TYPE=Ethernet' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    echo 'GATEWAY=192.168.1.1' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    echo 'NETMASK=255.255.255.0' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    if [ $x == "node1" ];then
      echo 'IPADDR=192.168.1.51' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    elif [ $x == "node2" ];then
      echo 'IPADDR=192.168.1.52' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth0
    fi

    echo '' 		> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'DEVICE=eth1' 		>> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'BOOTPROTO=dhcp' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'ONBOOT=yes' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo "DHCP_HOSTNAME=$x\-priv1" >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'NM_CONTROLLED=no' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'TYPE=Ethernet' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1

    echo '' 		> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'DEVICE=eth2' 		>> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'BOOTPROTO=dhcp' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'ONBOOT=yes' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo "DHCP_HOSTNAME=$x\-priv2" >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'NM_CONTROLLED=no' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'TYPE=Ethernet' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2

    echo '' > /container/$x/rootfs/etc/hosts
    echo '127.0.0.1 localhost.localdomain localhost ::1 localhost6.localdomain6 localhost6' >> /container/$x/rootfs/etc/hosts
    echo '192.168.1.50 scan' >> /container/$x/rootfs/etc/hosts
    echo '192.168.1.51 node1' >> /container/$x/rootfs/etc/hosts
    echo '192.168.1.52 node2' >> /container/$x/rootfs/etc/hosts
    echo '192.168.1.51 node1-vip' >> /container/$x/rootfs/etc/hosts
    echo '192.168.1.52 node2-vip' >> /container/$x/rootfs/etc/hosts

  fi

done
