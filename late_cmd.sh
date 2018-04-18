#! /bin/sh
## Extra commands after fresh Debian install,
## before first boot
## See preseed/late_command

## SSH pubkeys
keys_url="https://f.seanho.com/vps/keys"
keys_tmp="/tmp/authorized_keys"

wget -qO $keys_tmp "$keys_url"

mkdir -vpm 700 /root/.ssh
install -vDm 600 $keys_tmp /root/.ssh/
install -vDm 600 $keys_tmp /etc/dropbear-initramfs/

## SSH server (dropbear) config
echo "DROPBEAR_OPTIONS=\"-p 26 -s\"" >> /etc/dropbear-initramfs/config

#egrep -q "^[^#]*$opt=[^#]*$db_opts" $db_cfg || \
#  echo "$opt=\"\$$opt $db_opts\"" >> $db_cfg

update-initramfs -u
