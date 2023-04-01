#!/bin/bash

export IMAGE=./armbian.img

echo "Erasing ssd..."
dd bs=1M if=/dev/zero of=/dev/nvme0n1 count=2000 status=progress
sync

echo "Writing image to ssd..."
dd bs=1M if=$IMAGE of=/dev/nvme0n1 status=progress
sync

echo "Verifying..."
md5sum /dev/nvme0n1 $IMAGE

echo "Post writing tasks..."
armbian-install

echo "Checking filesystem..."
fsck -yf /dev/nvme0n1

echo "Halting..."
halt
