#!/bin/bash
set +x 

# =========================
# Variables
# =========================
RAM=4096
DISK=64000      # en Mo
TYPE_OS="Debian_64"
ACTION=$1
NAME=$2
DIR="$HOME/VirtualBox VMs/$NAME"
DISK_PATH="$DIR/$NAME.vdi"

if [ $# -lt 1 ]; then
    echo "Usage : $0 <L|N|S|D|A> [Nom_VM]"
    exit 1
fi


case "$ACTION" in

    # --- Lister les machines ---
    L)
        echo ">>> Liste des machines virtuelles :"
        vboxmanage list vms
        ;;

    # --- Créer une nouvelle machine ---
    N)
        if [ -z "" ]; then
            echo "Erreur : vous devez fournir un nom de VM."
            exit 1
        fi

        if [ $? -ne 0 ]; then 
    		echo "Erreur : impossible de créer la VM $NAME car elle existe déjà."
   			exit 1
		fi

        echo ">>> Création de la VM $NAME..."
        vboxmanage createvm --name "$NAME" --ostype "$TYPE_OS" --register
        vboxmanage modifyvm "$NAME" --memory $RAM --nic1 nat --boot1 net

        mkdir -p "$DIR"
        vboxmanage createmedium disk --filename "$DISK_PATH" --size $DISK
        vboxmanage storagectl "$NAME" --name "SATA Controller" --add sata --controller IntelAhci
        vboxmanage storageattach "$NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$DISK_PATH"

        echo ">>> VM $NAME créée avec succès !"
        ;;

    # --- Supprimer une machine ---
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

    # --- Démarrer une machine ---
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

    # --- Arrêter une machine ---
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

esac

