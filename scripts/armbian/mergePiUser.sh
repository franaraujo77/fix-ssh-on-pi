#!/bin/bash

mv /home/ksys/.bashrc /home/ksys/.bashrc.old
cp /home/pi/.bashrc /home/ksys/.bashrc
chown ksys:ksys /home/ksys/.bashrc
userdel pi
