#!/bin/bash
set +x 

# =========================
# Variables
# =========================
DISK=64000      # en Mo
TYPE_OS="Debian_64"
ACTION=$1
NAME=$2
RAM=$3
DIR="$HOME/VirtualBox VMs/$NAME"
DISK_PATH="$DIR/$NAME.vdi"

if [ $# -lt 1 ]; then
    echo "Usage : $0 <L|N|S|D|A> [Nom_VM]"
    exit 1
fi


case "$ACTION" in

    # --- Lister les machines ---
    L)
                echo ">>> Liste des VMs :"
        vboxmanage list vms | while read -r line; do
            NAME_VM=$(echo "$line" | cut -d '"' -f 2)
            echo "Machine : $NAME_VM"
            vboxmanage getextradata "$NAME_VM" "CreatedOn" | sed 's/^.*Value: //'
            vboxmanage getextradata "$NAME_VM" "Owner" | sed 's/^.*Value: //'
			vboxmanage getextradata "$NAME_VM" "RAM" | sed 's/^.*Value: //'

            echo "---------------------------"
		done
        ;;


    # Créer nouvelle VM
    N)
    if [ -z "$NAME" ]; then
        echo "Erreur : vous devez fournir un nom de VM."
        exit 1
    fi
	
	if [ -z "$RAM" ]; then
            echo "Erreur : vous devez fournir la taille de la RAM (en Mo)."
            exit 1
    fi

    if ! [[ "$RAM" =~ ^[0-9]+$ ]]; then
            echo "Erreur : la RAM doit être un nombre (en Mo)."
            exit 1
    fi

    # (Vérifier si la VM existe déjà)
    if vboxmanage list vms | grep -q "\"$NAME\""; then
        echo "Erreur : la VM $NAME existe déjà."
        exit 1
    fi

    DIR="$HOME/VirtualBox VMs/$NAME"
    DISK_PATH="$DIR/$NAME.vdi"

    echo ">>> Création de la VM $NAME..."
    vboxmanage createvm --name "$NAME" --ostype "$TYPE_OS" --register
    vboxmanage modifyvm "$NAME" --memory $RAM --nic1 nat --boot1 net

    vboxmanage setextradata "$NAME" "CreatedOn" "$(date)"
    vboxmanage setextradata "$NAME" "Owner" "$USER"
	vboxmanage setextradata "$NAME" "RAM" "$RAM"


    mkdir -p "$DIR"
    vboxmanage createmedium disk --filename "$DISK_PATH" --size $DISK
    vboxmanage storagectl "$NAME" --name "SATA Controller" --add sata --controller IntelAhci
    vboxmanage storageattach "$NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$DISK_PATH"

    echo ">>> VM $NAME créée avec succès !"
    ;;

    # Suppr
    S)
        if [ -z "$NAME" ]; then
            echo "Erreur : vous devez fournir le nom de la VM à supprimer."
            exit 1
        fi

        if vboxmanage list vms | grep -q "\"$NAME\""; then
            echo ">>> Suppression de la VM $NAME..."
            vboxmanage unregistervm "$NAME" --delete
            echo ">>> VM $NAME supprimée."
        else
            echo "Erreur : la VM $NAME n'existe pas."
        fi
        ;;

    # Démarrer VM
    D)
        if [ -z "$NAME" ]; then
            echo "Erreur : vous devez fournir le nom de la VM à démarrer."
            exit 1
        fi

        if vboxmanage list vms | grep -q "\"$NAME\""; then
            echo ">>> Démarrage de la VM $NAME..."
            vboxmanage startvm "$NAME" --type gui
        else
            echo "Erreur : la VM $NAME n'existe pas."
        fi
        ;;

    # Arrêter VM
    A)
        if [ -z "$NAME" ]; then
            echo "Erreur : vous devez fournir le nom de la VM à arrêter."
            exit 1
        fi

        if vboxmanage list runningvms | grep -q "\"$NAME\""; then
            echo ">>> Arrêt de la VM $NAME..."
            vboxmanage controlvm "$NAME" poweroff
            echo ">>> VM $NAME arrêtée."
        else
            echo "Erreur : la VM $NAME n'est pas en cours d'exécution."
        fi
        ;;

	# Suppr All
    SA)
        echo ">>> Suppression de toutes les machines virtuelles..."
        vboxmanage list vms | while read -r line; do
            NAME_VM=$(echo "$line" | cut -d '"' -f 2)
            echo ">>> Suppression de la VM $NAME_VM..."
            vboxmanage unregistervm "$NAME_VM" --delete
        done
        echo ">>> Toutes les machines ont été supprimées."
        ;;

esac

