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

    echo 'DEVICE=eth1' 		>> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'BOOTPROTO=dhcp' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'ONBOOT=yes' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo "DHCP_HOSTNAME=$x" >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'NM_CONTROLLED=no' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1
    echo 'TYPE=Ethernet' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth1

    echo 'DEVICE=eth2' 		>> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'BOOTPROTO=dhcp' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'ONBOOT=yes' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo "DHCP_HOSTNAME=$x" >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'NM_CONTROLLED=no' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
    echo 'TYPE=Ethernet' >> /container/$x/rootfs/etc/sysconfig/network-scripts/ifcfg-eth2
  fi
done
