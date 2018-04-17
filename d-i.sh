#! /bin/bash
## Configure grub for Debian netinstall
#apt-get -qq install git wget gettext-base

arch="amd64"
url="http://ftp.debian.org/debian/dists/stable/main/installer-$arch/current/images/netboot/debian-installer/$arch"

repo="https://github.com/ho-ansible/d-i"

# Clone git repo, use as working dir
cd /boot
repodir=$(basename $repo)
if [ -d "$repodir/.git" ]; then
  cd "$repodir"
  git pull
else
  git clone --depth 1 $repo
  cd "$repodir"
fi

# Download Debian netboot kernel/ramdisk
for file in linux initrd.gz; do
  wget -N "$url/$file"
done

# Read current network config
declare -A cfg

# sets $dev, $src, and $via
eval x=$(ip ro get 8.8.8.8 | sed 's/\([a-z]\)\s\+/\1=/g')
cfg[IPADDRESS]="$src"
cfg[GATEWAY]="${via:-}"
cfg[NAMESERVERS]="8.8.8.8"

host=$(hostname -s)
domain=$(hostname -d)
cfg[HOSTNAME]="${host:-debian}"
cfg[DOMAIN]="${domain:-example.com}"

# Other variables for preseed.cfg
cfg[DMCRYPT_PASS]="3ChcPn7nTdjlvLUw6WgH"

# Process preseed file (envsubst is in gettext-base)
cfgvars=( ${!cfg[@]} )
for v in "${cfgvars[@]}"; do
  export "$v"="${cfg[$v]}"
done
envsubst "${cfgvars[*]/#/$}" < d-i/stretch/preseed.cfg > preseed.cfg

# Insert preseed into initrd
zcat initrd.gz > initrd-preseed
echo preseed.cfg | cpio -H newc -o -A -F initrd-preseed
gzip -f initrd-preseed

# Configure GRUB2
install -Cv -o root -g root -m 755 grub.d/* /etc/grub.d/
update-grub

