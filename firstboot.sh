#!/bin/bash

function log () {
  DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"` #add %3N as we want millisecond too
  echo "${DATE_WITH_TIME} $1" >> /boot/firstboot.log
}

log "Start execution"
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