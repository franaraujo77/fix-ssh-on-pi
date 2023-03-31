#!/bin/bash

export IMAGE=./armbian.img

dd bs=1M if=/dev/zero of=/dev/nvme0n1 count=2000 status=progress
sync
md5sum /dev/nvme0n1 /dev/zero

armbian-install

dd bs=1M if=$IMAGE of=/dev/nvme0n1 status=progress
sync
md5sum /dev/nvme0n1 $IMAGE

fsck -yf /dev/nvme0n1

halt
