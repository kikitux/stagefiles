#!/bin/bash
#take care of some prerequirements

if [ ! $1 ]; then
  #setup local yum repo
  [ -f /etc/yum.repos.d/public-yum-ol6.repo ] && mv /etc/yum.repos.d/public-yum-ol6.repo{,.ori}
  curl -o /etc/yum.repos.d/local.repo http://192.168.56.1/stage/vbox-yum-ol6.repo
else
  [ -f /etc/yum.repos.d/local.repo ] && \rm /etc/yum.repos.d/local.repo
  [ -f /etc/yum.repos.d/public-yum-ol6.repo.ori ] && \mv /etc/yum.repos.d/public-yum-ol6.repo{.ori,}
fi

