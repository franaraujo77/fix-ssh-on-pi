#!/bin/bash

echo ""
echo "Downloading OS 64 image"
echo ""

docker run --privileged --mount src="${PWD}",target=/opt/fix-pi,type=bind ubuntu /opt/fix-pi/run-step1-64.bash

echo ""
echo "Preparing OS 64 image"
echo ""

docker run --privileged --mount src="${PWD}",target=/opt/fix-pi,type=bind ubuntu /opt/fix-pi/run-step2-64.bash

rm -rf raspbian_image.zip

echo ""
echo "Downloading OS HF image"
echo ""

docker run --privileged --mount src="${PWD}",target=/opt/fix-pi,type=bind ubuntu /opt/fix-pi/run-step1-hf.bash

echo ""
echo "Preparing OS HF image"
echo ""

docker run --privileged --mount src="${PWD}",target=/opt/fix-pi,type=bind ubuntu /opt/fix-pi/run-step2-hf.bash

echo ""
echo "All jobs done"
echo ""