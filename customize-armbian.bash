#!/bin/bash

echo ""
echo "Downloading OS image"
echo ""

docker run --privileged --mount src="${PWD}",target=/opt/fix-pi,type=bind ubuntu /opt/fix-pi/run-step1-armbian.bash

echo ""
echo "Preparing OS image"
echo ""

docker run --privileged --mount src="${PWD}",target=/opt/fix-pi,type=bind ubuntu /opt/fix-pi/run-step2-armbian.bash

rm -rf raspbian_image.zip

echo ""
echo "All jobs done"
echo ""