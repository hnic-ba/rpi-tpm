#!/bin/bash
# Update /boot/config.txt to support the TPM module. Must be ran as root.

set -e

CONFIG=/boot/config.txt
NOW=$(date +%F_%H%M)
updated_config="false"

I_ECHO(){
    echo "$(date +%F\ %T); $@"
}

[ ! -f $CONFIG ] && I_ECHO "Something is wrong. Missing boot config /boot/config.txt" && exit 0

# Back up config
cp -a $CONFIG{,-$NOW}

for c in "dtoverlay=tpm-slb9670" "dtparam=spi=on"; do
    if ! grep -qE ^$c\$ $CONFIG; then
	echo "$c" >> $CONFIG && updated_config="true"
    fi
done

if [ $updated_config == "false" ]; then
    I_ECHO "$CONFIG was not updated because the required parameters are already set."
    rm $CONFIG-$NOW
fi

I_ECHO "$CONFIG updated to enable tpm module. Reboot required."
