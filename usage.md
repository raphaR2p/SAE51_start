# Automatisation de la gestion des machines virtuelles VirtualBox

**Auteurs :** Raphael Mambo, Jeff Rasamison 
**Date :** 11/09/2025 

---

## Résumé
Ce document présente un script Bash permettant d’automatiser la gestion des machines virtuelles sous VirtualBox. Il décrit les fonctionnalités disponibles, la manière d’utiliser le script, ses limites et les difficultés rencontrées lors du développement. Il sert de guide pratique pour créer, démarrer, arrêter, lister et supprimer des VMs facilement.

---

## Objectifs
- Automatiser la création de VMs avec des paramètres prédéfinis.
- Permettre le démarrage et l’arrêt des VMs via une interface en ligne de commande.
- Fournir un mécanisme simple de suppression des VMs avec confirmation pour éviter les erreurs.
- Ajouter un suivi basique via des métadonnées (date de création, propriétaire, RAM).

---

## Fonctionnement du script
Le script utilise `vboxmanage` pour effectuer toutes les actions sur les VMs. Les principales fonctionnalités sont :

1. **Lister les VMs existantes** :
   Affiche le nom, le propriétaire, la date de création et la RAM allouée de chaque VM.

2. **Créer une VM** :
   - Nom et RAM obligatoires.
   - Création d’un disque virtuel de taille prédéfinie.
   - Configuration du contrôleur SATA et attachement du disque.
   - Ajout des métadonnées (date de création, propriétaire, RAM).

3. **Démarrer une VM** :
   - Démarrage en mode GUI.
   - Vérification que la VM existe avant lancement.

4. **Arrêter une VM** :
   - Vérification que la VM est en cours d’exécution.

5. **Supprimer une VM** :
   - Confirmation demandée avant suppression.
   - Supprime le registre VirtualBox et le disque associé.

6. **Supprimer toutes les VMs** :
   - Confirmation obligatoire pour éviter la suppression accidentelle.

## Actions disponibles:
   - L : Lister toutes les VMs existantes.
   - N : Créer une nouvelle VM (requiert Nom_VM et RAM).
   - S : Supprimer une VM (requiert Nom_VM).
   - D : Démarrer une VM (requiert Nom_VM).
   - A : Arrêter une VM (requiert Nom_VM).
   - SA : Supprimer toutes les VMs (confirmation requise).

---

## Limites
   - Certains paramètres matériels (taille du disque, CPU, type d'OS) sont codés en dur.
   - Les chemins d'installation peuvent varier selon le système, ce qui peut causer des erreurs si le répertoire par défaut n'existe pas.
   - Prévu pour fonctionner uniquement sur linux.

## Problèmes rencontrés
   - **Validation des arguments**
	Au début, nous avons oublié de vérifier si l’utilisateur fournissait un nom de VM ou une taille de RAM. Résultat : le script plantait silencieusement quand on lançait ./vm.sh N sans arguments. Nous avons dû ajouter des conditions pour afficher des messages d’erreur clairs et arrêter l’exécution proprement.
   - **Permissions et chemins d’installation**
	Lors de nos premiers tests, le script essayait de créer des dossiers dans $HOME/VirtualBox VMs, mais sur certaines machines, le répertoire n’existait pas et nous n’avions pas les droits suffisants. Cela a provoqué plusieurs échecs lors de la création des VMs. Nous avons donc intégré la création automatique des dossiers et la vérification des permissions avant chaque opération.

---

## Utilisation

Commande générale : 

```bash
./vm.sh <ACTION> [Nom_VM] [RAM]

