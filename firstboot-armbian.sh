#!/bin/bash

exec >> /boot/firstboot.log
exec 2>&1

function log () {
  DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"` #add %3N as we want millisecond too
  echo "${DATE_WITH_TIME} $1" >> /boot/firstboot.log
}

log "Start execution"

log "Add default user"
useradd -m -s /bin/bash -G tty,disk,dialout,sudo,audio,video,plugdev,games,users,systemd-journal,input,netdev ksys
cp -R /root/.ssh /home/ksys
chown -R ksys:ksys /home/ksys/.ssh
echo "ksys	ALL = (ALL)  NOPASSWD: ALL" >> /etc/sudoers

#log "Add opt mount point"
#dd bs=1M if=/dev/zero of=/dev/nvme0n1 count=2000 status=progress
#sync
#blkid --match-token TYPE=ext4 /dev/nvme0n1 || \
#                  mkfs -t ext4 /dev/nvme0n1 && \
#                  echo "/dev/nvme0n1 /opt auto defaults 0 2" >> /etc/fstab
#mkdir /opt
#chown -R ksys:ksys /opt

log "Install htpdate to synchronize date and time automatically"
apt install htpdate -y

#log "Update apt cache and upgrade packages"
#apt update
#DEBIAN_FRONTEND=noninteractive   apt-get   -o Dpkg::Options::=--force-confold upgrade -y

log "Update hostname"
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