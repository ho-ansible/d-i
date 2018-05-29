#! /bin/bash
## Configure grub for Debian netinstall

arch="amd64"
release="stable"

url="http://ftp.debian.org/debian/dists/$release/main/installer-$arch/current/images/netboot/debian-installer/$arch"

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

# Parse current network config into associative array
declare -A cfg

# sets $dev, $src, and $via
eval x=$(ip ro get 8.8.8.8 | sed -E 's/( [a-z]+) +/\1=/g')
cfg[IPADDRESS]="$src"
cfg[GATEWAY]="${via:-}"
cfg[NAMESERVERS]="8.8.8.8"

host=$(hostname -s)
domain=$(hostname -d)
cfg[HOSTNAME]="${host:-debian}"
cfg[DOMAIN]="${domain:-example.com}"

# Plaintext: change with cryptsetup after system is installed
cfg[DMCRYPT_PASS]="retired axiomatic cactus swing"

# Disable password login for root
cfg[ROOT_PASS]="!"
cfg[ROOT_PASS]="$6$rounds=656000$T8zQxx5QdYCFEO8k$IEsy4L6X6h85UvfxsnVPRbGrztxqhRQNWd.NX6ZcUlJBfsfp.uLld/PGYE6EHw2U/quRnpcoysThR33nv3rW5."

# Process preseed file 
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

