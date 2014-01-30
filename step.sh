#!/bin/bash
THISFILE=$(basename "${0}")
THISDIR=${0%$THISFILE}

HOST=$(hostname -s)

if [ -c /dev/lxc/console ]; then
  echo -en '\E[47;34m'"\033[1mHost is $HOST, an lxc container. Executing: $@ \033[0m"   # Blue
else
  echo -en '\E[47;35m'"\033[1mHost is $HOST, not an lxc container. Executing: $@ \033[0m"   # Magenta
fi
echo " "
#end colors
tput sgr0
echo " "

$@ 2> ${THISDIR}/${THISFILE%.sh}.err >> ${THISDIR}/${THISFILE%.sh}.log
