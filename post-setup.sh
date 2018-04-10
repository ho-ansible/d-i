#! /bin/sh
## Extra commands after fresh Debian install,
## before first boot
## Usage: in preseed config:
## d-i preseed/late_command string \
##   wget -O- https://d-i.seanho.com/post-setup.sh | in-target /bin/sh -

keys_url="https://f.seanho.com/vps/authorized_keys"
keys_tmp="/tmp/authorized_keys"

wget -O $keys_tmp "$keys_url"

install -Dv -m 600 $keys_tmp /root/.ssh/
install -Dv -m 600 $keys_tmp /etc/dropbear-initramfs/

db_opts="-p 26 -s"
db_cfg="/etc/dropbear-initramfs/config"
opt="DROPBEAR_OPTIONS"

egrep -q "^[^#]*$opt=[^#]*$db_opts" $db_cfg || \
  echo "$opt=\"\$$opt $db_opts\"" >> $db_cfg

#  sed -i $db_cfg -re "s/^([^#]*$opt=\")(.*)$/\1$db_opts \2/"

update-initramfs -u
