#!/bin/bash
# MIT License 
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# v1.1 - changes to reflect that the sha_sum is now SHA-256
#        Moved ethernet naming to firstboot.sh

# Credits to:
# - http://hackerpublicradio.org/correspondents.php?hostid=225
# - https://gpiozero.readthedocs.io/en/stable/pi_zero_otg.html#legacy-method-sd-card-required
# - https://github.com/nmcclain/raspberian-firstboot

variables=(
  root_password_clear
  public_key_file
  image_to_download
  url_base
  armbian_compressed_image
  extracted_image
)

for variable in "${variables[@]}"
do
  if [[ -z ${!variable+x} ]]; then   # indirect expansion here
    echo "ERROR: The variable \"${variable}\" is missing from your \""${settings_file}"\" file.";
    exit 2
  fi
done

sdcard_mount="/mnt/sdcard"

if [ $(id | grep 'uid=0(root)' | wc -l) -ne "1" ]
then
    echo "You are not root "
    exit
fi

if [ ! -e "${public_key_file}" ]
then
    echo "Can't find the public key file \"${public_key_file}\""
    echo "You can create one using:"
    echo "   ssh-keygen -t ed25519 -f ./${public_key_file} -C \"Armbian keys\""
    exit 3
fi

function umount_sdcard () {
    umount "${sdcard_mount}"
    if [ $( ls -al "${sdcard_mount}" | wc -l ) -eq "3" ]
    then
        echo "Sucessfully unmounted \"${sdcard_mount}\""
        sync
    else
        echo "Could not unmount \"${sdcard_mount}\""
        exit 4
    fi
}

# Download the latest image, using the  --continue "Continue getting a partially-downloaded file"
wget --continue ${image_to_download} -O ${armbian_compressed_image}

armbian_image=$( ls *.img.xz )

if [ ! -e ${armbian_compressed_image} ]
then
    echo "Can't find the compressed image \"${armbian_compressed_image}\""
    exit 5
fi

if [ ! -d "${sdcard_mount}" ]
then
  mkdir ${sdcard_mount}
fi

# unzip
echo "The name of the image is \"${extracted_image}\""

7z x -y ${armbian_compressed_image}

if [ ! -e ${extracted_image} ]
then
    echo "Can't find the image \"${extracted_image}\""
    exit 6
fi

umount_sdcard
echo "Mounting the sdcard boot disk"

loop_base=$( losetup --partscan --find --show "${extracted_image}" )

echo "Running: mount ${loop_base}p1 \"${sdcard_mount}\" "
mount ${loop_base}p1 "${sdcard_mount}"
ls -al /mnt/sdcard

echo ""
echo "Ready for next step!!!"
echo ""
