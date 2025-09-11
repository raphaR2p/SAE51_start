# Automatisation de la gestion des machines virtuelles VirtualBox

**Auteurs :** Raphael Mambo, Jeff Rasamison  
**Date :** 11/09/2025  

---

## Résumé
Ce document présente un script Bash permettant d’automatiser la gestion des machines virtuelles sous VirtualBox. Il décrit les fonctionnalités disponibles, la manière d’utiliser le script, ses limites et les difficultés rencontrées lors du développement. Il sert de guide pratique pour créer, démarrer, arrêter, lister et supprimer des VMs facilement.

---

## Contexte
VirtualBox est un logiciel de virtualisation permettant de créer et gérer plusieurs systèmes d’exploitation sur une seule machine. Gérer les VMs via l’interface graphique peut être long et répétitif, surtout lorsqu’il s’agit de créer plusieurs VMs avec des paramètres similaires.  
Le script présenté ici a été développé pour automatiser ces tâches et faciliter la gestion des VMs dans un environnement Linux.

---

## Objectifs
- Automatiser la création de VMs avec des paramètres prédéfinis.  
- Permettre le démarrage et l’arrêt rapide des VMs via une interface en ligne de commande.  
- Fournir un mécanisme simple de suppression des VMs avec confirmation pour éviter les erreurs.  
- Ajouter un suivi basique via des métadonnées (date de création, propriétaire, RAM).  

---

## Fonctionnement du script
Le script utilise `vboxmanage`, l’outil en ligne de commande de VirtualBox, pour effectuer toutes les actions sur les VMs. Les principales fonctionnalités sont :

1. **Lister les VMs existantes** :  
   Affiche le nom, le propriétaire, la date de création et la RAM allouée de chaque VM.

2. **Créer une VM** :  
   - Nom et RAM obligatoires.  
   - Création d’un disque virtuel `.vdi` de taille prédéfinie.  
   - Configuration du contrôleur SATA et attachement du disque.  
   - Ajout des métadonnées (date de création, propriétaire, RAM).  

3. **Démarrer une VM** :  
   - Démarrage en mode GUI.  
   - Vérification que la VM existe avant lancement.

4. **Arrêter une VM** :  
   - Arrêt via `controlvm poweroff`.  
   - Vérification que la VM est en cours d’exécution.

5. **Supprimer une VM** :  
   - Confirmation demandée avant suppression.  
   - Supprime le registre VirtualBox et le disque associé.  

6. **Supprimer toutes les VMs** :  
   - Confirmation obligatoire pour éviter la suppression accidentelle.  

---

## Utilisation

Commande générale :  

```bash
./vm.sh <ACTION> [Nom_VM] [RAM]

