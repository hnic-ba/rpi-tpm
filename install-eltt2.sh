#!/bin/bash
# Purpose: Clone eltt2 repo, compile and install

set -e

I_ECHO(){
    echo "$(date +%F\ %T); $@"
}

if ! dpkg -s git &>/dev/null; then
    I_ECHO "Installing git."
    sudo apt update >/dev/null
    sudo apt install git
fi

if [ ! -d eltt2 ]; then
    I_ECHO "Cloning eltt2 repo."
    git clone https://github.com/Infineon/eltt2 && cd eltt2
else

    I_ECHO "Found eltt2 repo, checking for updates."
    cd eltt2 && git pull
fi

I_ECHO "Compiling eltt2."
make
save_rc=$?
if [ $save_rc -gt 0 ]; then
    I_ECHO "make failure on line $BASH_SOURCE:$LINENO with rc $save_rc"
    exit $save_rc
fi

if [ ! -f eltt2 ];then
    I_ECHO "Missing eltt2 after make. Something went wrong."
    exit 1
fi

if [ ! -d ~/bin ]; then
    mkdir -p ~/bin
fi

if [ -f ~/bin/eltt2 ] && diff eltt2 ~/bin/eltt2 &>/dev/null; then
    I_ECHO "~/bin/eltt2 found and is different than the new version."
    I_ECHO "Manual action required to add the upgraded version to the PATH. New compiled version is located at $(pwd)/eltt2"
    exit 0
fi

I_ECHO "Adding eltt2 to ~/bin."
cp eltt2 ~/bin

if ! grep -q "export PATH=\$PATH:~/bin" ~/.bashrc; then
    I_ECHO "Updating .bashrc (Adding ~/bin to PATH)."
    echo "export PATH=\$PATH:~/bin" >> ~/.bashrc
    source ~/.bashrc
fi
