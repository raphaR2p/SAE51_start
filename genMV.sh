#!/bin/bash
set +x 

# =========================
# Variables
# =========================
NAME="test3"
RAM=4096
DISK=64000      # en Mo
TYPE_OS="Debian_64"
DIR="$HOME/VirtualBox VMs/$NAME"
DISK_PATH="$DIR/$NAME.vdi"

# =========================
# Création de la VM
# =========================
echo ">>> Création de la VM $NAME..."

vboxmanage createvm --name "$NAME" --ostype "$TYPE_OS" --register 2>/dev/null
if [ $? -ne 0 ]; then 
    echo "Erreur : impossible de créer la VM $NAME car elle existe déjà."
    exit 1
fi

# Configuration mémoire et réseau (NAT + boot PXE)
vboxmanage modifyvm "$NAME" --memory $RAM --nic1 nat --boot1 net

# Création du disque
mkdir -p "$DIR"
vboxmanage createmedium disk --filename "$DISK_PATH" --size $DISK

# Ajout du contrôleur SATA
vboxmanage storagectl "$NAME" --name "SATA Controller" --add sata --controller IntelAhci

# Attacher le disque
vboxmanage storageattach "$NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$DISK_PATH"

echo ">>> VM $NAME créée avec succès !"

# =========================
# Pause pour vérifier la VM
# =========================
#read -p "Appuie sur Entrée pour supprimer la VM..."

# =========================
# Suppression de la VM
# =========================
#vboxmanage unregistervm "$NAME" --delete
#echo ">>> VM $NAME supprimée."

