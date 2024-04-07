#!/bin/bash

printf "\nDownloading OS image\n"
printf "#########################################################################################################\n"

docker run --privileged --mount src="${PWD}",target=/opt/fix-pi,type=bind ubuntu /opt/fix-pi/run-step1-ubuntu.bash

printf "\nPreparing OS image\n"
printf "#########################################################################################################\n"

docker run --privileged --mount src="${PWD}",target=/opt/fix-pi,type=bind ubuntu /opt/fix-pi/run-step2-ubuntu.bash

rm -rf ubuntu.img.xz

printf "#########################################################################################################\n"
printf "\nAll jobs done\n"
printf "#########################################################################################################\n"
