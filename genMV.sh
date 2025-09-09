#!/bin/bash
set +x 

RAM=4096      
DISK=64000    
TYPE_OS="Debian_64"
DIR="$HOME/VirtualBox VMs/test2"
NAME=test2

vboxmanage createvm --name="$NAME" 2>/dev/null
if [ $? != 0 ]
then
	echo "erreur"
	exit 1
fi

vboxmanage registervm "/home/fi25-mambo/VirtualBox VMs/test2/test2.vbox"
