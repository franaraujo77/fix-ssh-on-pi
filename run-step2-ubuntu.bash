#!/bin/bash

apt update
apt install wget p7zip-full python3 -y

cd /opt/fix-pi

# Change the settings in the file mentioned below.
settings_file="fix-ssh-on-ubuntu.ini"

# You should not need to change anything beyond here.

if [ -e "${settings_file}" ]
then
  source "${settings_file}"
elif [ -e "${HOME}/${settings_file}" ]
then
  source "${HOME}/${settings_file}"
elif [ -e "${0%.*}.ini" ]
then
  source "${0%.*}.ini"
else
  echo "ERROR: Can't find the Settings file \"${settings_file}\""
  exit 1
fi

./fix-ssh-on-ubuntu-step2.bash