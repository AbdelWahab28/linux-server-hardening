# Phase 4 — Mise en place du pare-feu avec UFW

## Objectif

Cette phase consiste à mettre en place un pare-feu local sur le serveur Linux afin de contrôler les connexions réseau entrantes et sortantes.

Le principe appliqué est celui du **moindre privilège réseau** : les connexions entrantes sont refusées par défaut et seuls les services nécessaires à l'administration ou au fonctionnement du serveur sont explicitement autorisés.

> **Attention :** lorsque le serveur est administré à distance, la règle SSH doit être configurée avant l'activation du pare-feu afin d'éviter de perdre la connexion.

---

## 1. Vérification de l'installation d'UFW

On commence par vérifier si UFW est disponible :

```bash
sudo ufw status
```

Si UFW n'est pas installé :

```bash
sudo apt update
sudo apt install ufw
```

Puis :

```bash
sudo ufw status
```

---

## 2. Vérification de la configuration actuelle

Avant de modifier le pare-feu, on vérifie son état :

```bash
sudo ufw status verbose
```

Les règles existantes peuvent être affichées avec :

```bash
sudo ufw status numbered
```

Cette vérification permet d'éviter de modifier ou de supprimer accidentellement une règle déjà présente.

---

## 3. Configuration des politiques par défaut

Le serveur adopte une politique restrictive pour les connexions entrantes :

```bash
sudo ufw default deny incoming
```

Les connexions sortantes restent autorisées :

```bash
sudo ufw default allow outgoing
```

La politique obtenue est donc :

| Trafic  | Politique           |
| ------- | ------------------- |
| Entrant | Refusé par défaut   |
| Sortant | Autorisé par défaut |

Ainsi, un nouveau service installé sur le serveur n'est pas automatiquement accessible depuis l'extérieur.

---

## 4. Autorisation de SSH

Comme SSH est utilisé pour administrer le serveur à distance, il doit être autorisé avant l'activation d'UFW.

Dans notre configuration :

```bash
sudo ufw allow 22/tcp
```

Il est également possible d'utiliser le profil OpenSSH :

```bash
sudo ufw allow OpenSSH
```

Vérification :

```bash
sudo ufw status
```

> Dans le projet, SSH a été sécurisé lors de la phase précédente. La règle UFW doit donc correspondre au port SSH réellement utilisé par le serveur.

Si le port SSH a été modifié, par exemple vers `2222`, il faut utiliser :

```bash
sudo ufw allow 2222/tcp
```

---

## 5. Autorisation des services nécessaires

UFW ne doit pas être configuré pour ouvrir tous les ports possibles.

Seuls les services réellement utilisés doivent être autorisés.

### Serveur HTTP

Pour un serveur Web utilisant HTTP :

```bash
sudo ufw allow 80/tcp
```

### Serveur HTTPS

Pour HTTPS :

```bash
sudo ufw allow 443/tcp
```

### Vérification des profils disponibles

```bash
sudo ufw app list
```

Les profils disponibles dépendent des logiciels installés sur le serveur.

---

## 6. Activation du pare-feu

Une fois les règles nécessaires configurées :

```bash
sudo ufw enable
```

UFW peut afficher un avertissement concernant les connexions SSH.

La règle SSH ayant déjà été configurée, on peut confirmer l'activation :

```text
y
```

Le pare-feu devient alors actif.

---

## 7. Vérification du pare-feu

On vérifie son état :

```bash
sudo ufw status verbose
```

Puis les règles numérotées :

```bash
sudo ufw status numbered
```

Exemple :

```text
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
```

Les ports qui ne sont pas explicitement autorisés sont soumis à la politique `deny incoming`.

---

## 8. Vérification des services en écoute

La configuration du pare-feu doit être comparée aux services réellement exposés par le système.

On utilise :

```bash
sudo ss -tulpn
```

Cette commande permet d'identifier :

* les ports TCP en écoute ;
* les ports UDP en écoute ;
* les adresses d'écoute ;
* les processus associés.

L'objectif est de vérifier qu'il n'existe pas de service inutilement exposé.

---

## 9. Activation des logs UFW

La journalisation permet de conserver des informations sur les connexions réseau bloquées.

Activation :

```bash
sudo ufw logging on
```

Vérification :

```bash
sudo ufw status verbose
```

Les événements peuvent être consultés avec :

```bash
sudo journalctl -k | grep UFW
```

Selon la configuration du système, les événements peuvent également être présents dans :

```bash
sudo grep UFW /var/log/ufw.log
```

---

## 10. Vérification depuis une autre machine

Une vérification externe permet de confirmer que la politique réseau fonctionne réellement.

Depuis une autre machine :

```bash
nmap <IP_DU_SERVEUR>
```

Il faut vérifier que :

* le port SSH est accessible ;
* les ports des services nécessaires sont accessibles ;
* les ports inutiles ne sont pas exposés.

Le résultat doit correspondre aux services volontairement autorisés dans UFW.

---

## 11. Principe de sécurité appliqué

La configuration repose sur le principe :

> **Deny by default, allow by exception.**

Autrement dit :

1. les connexions entrantes sont bloquées par défaut ;
2. les services nécessaires sont identifiés ;
3. seuls leurs ports sont autorisés ;
4. les ports inutiles restent bloqués ;
5. la configuration est vérifiée après activation.

Cette approche limite la surface d'exposition réseau du serveur.

---

## 12. Automatisation

Le fichier `hardening.sh` automatise la configuration de base d'UFW.

Le script :

1. vérifie les privilèges administrateur ;
2. installe UFW s'il est absent ;
3. configure les politiques par défaut ;
4. autorise SSH ;
5. active la journalisation ;
6. active UFW ;
7. affiche les règles configurées.

Exécution :

```bash
chmod +x hardening.sh
sudo ./hardening.sh
```

---

## Résultat attendu

À la fin de cette phase :

* UFW est installé et actif ;
* les connexions entrantes sont refusées par défaut ;
* les connexions sortantes sont autorisées ;
* SSH est explicitement autorisé ;
* seuls les services nécessaires sont exposés ;
* les journaux UFW sont activés ;
* les règles sont vérifiées ;
* les ports réellement en écoute sont contrôlés.

Le serveur dispose ainsi d'une première couche de protection contre les connexions réseau non autorisées.

La phase suivante porte sur la **protection contre les attaques par force brute avec Fail2ban**.
