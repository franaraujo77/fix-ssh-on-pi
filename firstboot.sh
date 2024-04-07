#!/bin/bash

exec >> /boot/firstboot.log
exec 2>&1

function log () {
  DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"` #add %3N as we want millisecond too
  echo "${DATE_WITH_TIME} $1" >> /boot/firstboot.log
}

log "Start execution"

log "Install htpdate to synchronize date and time automatically and enable other software packages installation"
apt install htpdate -y

log "Update apt cache"
apt update

#log "Install required packages"
#apt install docker \
#    docker.io \
#    ansible \
#    -y

log "Update hostname configuration"
macadd=$( ip -brief add | awk '/UP/ {print $1}' | sort | head -1 )

log "macadd: ${macadd}"

if [ ! -z "${macadd}" ]
then
  macadd=$( sed 's/://g' /sys/class/net/${macadd}/address )
  sed "s/raspberrypi/${macadd}/g" -i /etc/hostname /etc/hosts
  log "hostname and hosts updated"
fi



/sbin/shutdown -r 5 "reboot in five minutes"

log "Finish execution"