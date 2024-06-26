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
  first_boot
  custom_scripts_folder
)

for variable in "${variables[@]}"
do
  if [[ -z ${!variable+x} ]]; then   # indirect expansion here
    echo "ERROR: The variable \"${variable}\" is missing from your \""${settings_file}"\" file.";
    exit 2
  fi
done

sdcard_mount="/mnt/sdcard"

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

if [ ! -d "${sdcard_mount}" ]
then
  mkdir ${sdcard_mount}
fi

# unzip
echo "The name of the image is \"${extracted_image}\""

if [ ! -e ${extracted_image} ]
then
    echo "Can't find the image \"${extracted_image}\""
    exit 6
fi

umount_sdcard
echo "Mounting the sdcard boot disk"

loop_fullpath=$( losetup -l | grep ${extracted_image}| awk '{print $1}' )
loop_base="/dev/$(basename ${loop_fullpath})" 

echo "Running: mount ${loop_base}p1 \"${sdcard_mount}\" "
mount ${loop_base}p1 "${sdcard_mount}"
ls -al /mnt/sdcard
if [ ! -e ${sdcard_mount}/Image ]
then
    echo "Can't find the mounted card\"${sdcard_mount}/Image\" kernel"
    exit 7
fi

touch "${sdcard_mount}/ssh"
if [ ! -e "${sdcard_mount}/ssh" ]
then
    echo "Can't find the ssh file \"${sdcard_mount}/ssh\""
    exit 9
fi

if [ -e "${first_boot}" ]
then
  cp -v "${first_boot}" "${sdcard_mount}/firstboot.sh"
fi

umount_sdcard

echo "Mounting the sdcard root disk"
echo "Running: mount ${loop_base}p2 \"${sdcard_mount}\" "
mount ${loop_base}p2 "${sdcard_mount}"
ls -al /mnt/sdcard

if [ ! -e "${sdcard_mount}/etc/shadow" ]
then
    echo "Can't find the mounted card\"${sdcard_mount}/etc/shadow\""
    exit 10
fi

if [ -e "${custom_scripts_folder}" ]
then
  cp -vR "${custom_scripts_folder}" "${sdcard_mount}/usr/local/bin/scripts"
  chown 1000:1000 "${sdcard_mount}/usr/local/bin/scripts"
  chmod -R ug+x "${sdcard_mount}/usr/local/bin/scripts"
fi

echo "Change the passwords and sshd_config file"

root_password="$( python3 -c "import crypt; print(crypt.crypt('${root_password_clear}', crypt.mksalt(crypt.METHOD_SHA512)))" )"
sed -e "s#^root:[^:]\+:#root:${root_password}:#" "${sdcard_mount}/etc/shadow" -i "${sdcard_mount}/etc/shadow"
#sed -e 's;^#PasswordAuthentication.*$;PasswordAuthentication no;g' -e 's;^PermitRootLogin .*$;PermitRootLogin no;g' -i "${sdcard_mount}/etc/ssh/sshd_config"
mkdir "${sdcard_mount}/root/.ssh"
chmod 0700 "${sdcard_mount}/root/.ssh"
chown 1000:1000 "${sdcard_mount}/root/.ssh"
cat ${public_key_file} >> "${sdcard_mount}/root/.ssh/authorized_keys"
chown 1000:1000 "${sdcard_mount}/root/.ssh/authorized_keys"
chmod 0600 "${sdcard_mount}/root/.ssh/authorized_keys"

echo "[Unit]
Description=FirstBoot
After=network-online.target
Wants=network-online.target
Before=rc-local.service
ConditionFileNotEmpty=/boot/firstboot.sh

[Service]
ExecStart=/boot/firstboot.sh
ExecStartPost=/bin/mv /boot/firstboot.sh /boot/firstboot.sh.done
Type=oneshot
RemainAfterExit=no

[Install]
WantedBy=multi-user.target" > "${sdcard_mount}/lib/systemd/system/firstboot.service"

cd "${sdcard_mount}/etc/systemd/system/multi-user.target.wants" && ln -s "/lib/systemd/system/firstboot.service" "./firstboot.service"
cd -

umount_sdcard

new_name="${extracted_image%.*}-ssh-enabled.img"

if [ -e "${new_name}" ]
then
    rm -rf ${new_name}
fi

losetup --detach ${loop_base}

mv -v "${extracted_image}" "${new_name}"

lsblk

echo ""
echo "Now you can burn the disk using something like:"
echo "      dd bs=4M status=progress if=${new_name} of=/dev/mmcblk????"
echo ""
