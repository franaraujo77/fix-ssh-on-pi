#!/bin/bash

export IMAGE=$1

if [[ -z "$IMAGE" ]]; then
    echo "It is mandatory to indicate an image"
    exit 1
fi

if [ ! -f "$IMAGE" ]; then
    echo "$IMAGE does not exist"
    exit 1
fi

echo "Erasing ssd..."
dd bs=1M if=/dev/zero of=/dev/nvme0n1 count=2000 status=progress
sync

echo "Writing image to ssd..."
dd bs=1M if=$IMAGE of=/dev/nvme0n1 status=progress
sync

#echo "Verifying..."
#md5sum /dev/nvme0n1 $IMAGE

#echo "Post writing tasks..."
#armbian-install

echo "Checking filesystem p1..."
fsck -yf /dev/nvme0n1p1

echo "Checking filesystem p2..."
fsck -yf /dev/nvme0n1p2

#echo "Halting..."
#halt
