#!/bin/bash

HOST=$(hostname -s)

if [ -c /dev/lxc/console ]; then
  echo -en '\E[47;34m'"\033[1mHost is $HOST, an lxc container. Executing: $@ \033[0m"   # Blue
else
  echo -en '\E[47;35m'"\033[1mHost is $HOST, not an lxc container. Executing: $@ \033[0m"   # Magenta
fi

echo " "
tput sgr0
$@ 2>/dev/null >> /media/sf_stagefiles/step.log
