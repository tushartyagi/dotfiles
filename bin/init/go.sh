#!/bin/bash

# Check out dotfiles and initiate bootstrap

set -e

if [ `whoami` != "root" ] ; then
  echo "You must be root."
  exit 1
fi

rm /usr/share/ca-certificates/mozilla/_ROOT.crt
rm /usr/share/ca-certificates/mozilla/China_Internet_Network_Information_Center_EV_Certificates_Root.crt

sed -i "s^mozilla/CNNIC^! mozilla/CNNIC^" /etc/ca-certificates.conf
sed -i "s^mozilla/China_Internet^! mozilla/China_internet^" /etc/ca-certificates.conf

update-ca-certificates

echo "APT::Install-Recommends \"0\";" > /etc/apt/apt.conf.d/50norecommends
echo "Package: systemd-sysv
Pin: release o=Debian
Pin-Priority: -1" > /etc/apt/preferences.d/no-systemd

apt-get update && apt-get install -y git zile sudo

if [ "$ME" = "" ]; then
  export ME=phil
  getent passwd phil || \
    (export ME=technomancy && getent passwd technomancy || \
     export ME=vagrant)
fi

usermod -a -G sudo $ME

# Allow control over interfaces that the installer hard-codes
if [ -r /etc/NetworkManager/NetworkManager.conf ]; then
    sed -i s/managed=false/managed=true/ /etc/NetworkManager/NetworkManager.conf
fi

# Don't wait to boot; just go with the default.
sed -i s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/ /etc/default/grub
update-grub

# Caps lock is absurd.
sed -i s/XKBOPTIONS=""/XKBOPTIONS="ctrl:nocaps"/ /etc/default/keyboard
dpkg-reconfigure -phigh console-setup

# Check repo out
if [ ! -r /home/$ME/.dotfiles ]; then
  echo "Checking out dotfiles..."
  sudo -u $ME git clone git://github.com/technomancy/dotfiles.git \
    /home/$ME/.dotfiles
fi

sudo -u $ME /home/$ME/.dotfiles/bin/link-dotfiles

exec /home/$ME/.dotfiles/bin/init/install.sh $ME
