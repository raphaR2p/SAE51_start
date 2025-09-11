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

# =========================
# Fonctions
# =========================
usage() {
    echo "Usage : $0 <ACTION> [Nom_VM] [RAM]"
    echo ""
    echo "Actions disponibles :"
    echo "  L        : Lister les VMs"
    echo "  N        : Créer une nouvelle VM (Nom_VM et RAM requis)"
    echo "  S        : Supprimer une VM (Nom_VM requis)"
    echo "  D        : Démarrer une VM (Nom_VM requis)"
    echo "  A        : Arrêter une VM (Nom_VM requis)"
    echo "  SA       : Supprimer toutes les VMs (confirmation demandée)"
    exit 1
}

# Vérification arguments
if [ $# -lt 1 ]; then
    usage
fi

require_name() {
    if [ -z "$NAME" ]; then
        echo "Erreur : vous devez fournir un nom de VM."
        exit 1
    fi
}

require_ram() {
    if [ -z "$RAM" ]; then
        echo "Erreur : vous devez fournir la taille de la RAM (en Mo)."
        exit 1
    fi
    if ! [[ "$RAM" =~ ^[0-9]+$ ]]; then
        echo "Erreur : la RAM doit être un nombre (en Mo)."
        exit 1
    fi
}

# =========================
# Actions
# =========================
case "$ACTION" in

    # --- Lister les machines ---
    L)
        echo ">>> Liste des VMs :"
        printf "%-20s %-20s %-25s %-10s\n" "Nom" "Propriétaire" "Créée le" "RAM"
        echo "--------------------------------------------------------------------------------"
        vboxmanage list vms | while read -r line; do
            NAME_VM=$(echo "$line" | cut -d '"' -f 2)
            OWNER=$(vboxmanage getextradata "$NAME_VM" "Owner" | sed 's/^.*Value: //')
            CREATED=$(vboxmanage getextradata "$NAME_VM" "CreatedOn" | sed 's/^.*Value: //')
            RAM=$(vboxmanage getextradata "$NAME_VM" "RAM" | sed 's/^.*Value: //')
            printf "%-20s %-20s %-25s %-10s\n" "$NAME_VM" "$OWNER" "$CREATED" "$RAM"
        done
        ;;

    # Créer nouvelle VM
    N)
        require_name
        require_ram

        # Vérifier si la VM existe déjà
        if vboxmanage list vms | grep -q "\"$NAME\""; then
            echo "Erreur : la VM $NAME existe déjà."
            exit 1
        fi

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

    # Supprimer une VM
    S)
        require_name

        if vboxmanage list vms | grep -q "\"$NAME\""; then
            read -p "⚠️  Êtes-vous sûr de vouloir supprimer la VM $NAME ? (y/N) " confirm
            if [[ $confirm == "y" || $confirm == "Y" ]]; then
                echo ">>> Suppression de la VM $NAME..."
                vboxmanage unregistervm "$NAME" --delete
                echo ">>> VM $NAME supprimée."
            else
                echo "Annulé."
            fi
        else
            echo "Erreur : la VM $NAME n'existe pas."
        fi
        ;;

    # Démarrer VM
    D)
        require_name
        if vboxmanage list vms | grep -q "\"$NAME\""; then
            echo ">>> Démarrage de la VM $NAME..."
            vboxmanage startvm "$NAME" --type gui
        else
            echo "Erreur : la VM $NAME n'existe pas."
        fi
        ;;

    # Arrêter VM
    A)
        require_name
        if vboxmanage list runningvms | grep -q "\"$NAME\""; then
            echo ">>> Arrêt de la VM $NAME..."
            vboxmanage controlvm "$NAME" poweroff
            echo ">>> VM $NAME arrêtée."
        else
            echo "Erreur : la VM $NAME n'est pas en cours d'exécution."
        fi
        ;;

    # Supprimer toutes les VMs
    SA)
        read -p "⚠️  Êtes-vous sûr de vouloir supprimer TOUTES les VMs ? (y/N) " confirm
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            echo ">>> Suppression de toutes les machines virtuelles..."
            vboxmanage list vms | while read -r line; do
                NAME_VM=$(echo "$line" | cut -d '"' -f 2)
                echo ">>> Suppression de la VM $NAME_VM..."
                vboxmanage unregistervm "$NAME_VM" --delete
            done
            echo ">>> Toutes les machines ont été supprimées."
        else
            echo "Annulé."
        fi
        ;;

    *)
        usage
        ;;
esac

