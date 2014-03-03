for x in $(mount -t btrfs | awk '{print $3}'); do
  [ -d $x/yum_* ] && ls -d $x/yum_* | xargs -n1 echo btrfs su delete 
done
