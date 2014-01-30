#initialize and mount the 4th disk only if there is no partitions

rpm -q ocfs2-tools > /dev/null
if [ $? -ne 0 ];then
  yum clean all
  yum -y install ocfs2-tools 
fi

blkid /dev/sdd*
if [ $? -ne 0 ]; then
  mkfs.ocfs2 -M local -T mail /dev/sdd
  blkid /dev/sdd 2>&1>/dev/null && echo $(blkid /dev/sdd -o export | head -n1) /u03 ocfs2 defaults 0 0 >> /etc/fstab
  mkdir -p /u03
  mount /u03
else
  echo "filesystem metadata found on sdd, ignoring"
fi

