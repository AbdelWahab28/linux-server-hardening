# Phase 0 — Préparation et état initial du serveur

## 📋 Sommaire

* [Objectif](#-objectif)
* [Principe](#-principe)
* [1. Vérification du système](#1-vérification-du-système)
* [2. Vérification de la version du noyau](#2-vérification-de-la-version-du-noyau)
* [3. Vérification de l'utilisateur courant](#3-vérification-de-lutilisateur-courant)
* [4. Vérification des privilèges administratifs](#4-vérification-des-privilèges-administratifs)
* [5. Vérification de l'espace disque](#5-vérification-de-lespace-disque)
* [6. Vérification de la mémoire](#6-vérification-de-la-mémoire)
* [7. Vérification du réseau](#7-vérification-du-réseau)
* [8. Mise à jour du système](#8-mise-à-jour-du-système)
* [9. Vérification des mises à jour](#9-vérification-des-mises-à-jour)
* [10. État initial du serveur](#10-état-initial-du-serveur)
* [11. Vérifications finales](#11-vérifications-finales)
* [Conclusion](#-conclusion)

---

# 🎯 Objectif

La première phase du projet consiste à **préparer le serveur avant d'appliquer les mesures de durcissement**.

Avant de modifier SSH, le pare-feu, les paramètres du noyau ou les services de sécurité, il est important de connaître précisément l'état initial de la machine.

Cette phase permet notamment de :

* identifier le système utilisé ;
* connaître la version du noyau ;
* identifier l'utilisateur courant ;
* vérifier les privilèges administratifs ;
* vérifier les ressources disponibles ;
* vérifier la connectivité réseau ;
* mettre le système à jour ;
* disposer d'un état de référence avant le durcissement.

> **Principe :** on ne sécurise pas correctement un serveur dont on ne connaît pas l'état initial.

---

# 🧠 Principe

Le serveur est considéré comme un système qui doit être progressivement transformé :

```text
Serveur nouvellement installé
            │
            ▼
    Identification du système
            │
            ▼
    Vérification des accès
            │
            ▼
    Vérification des ressources
            │
            ▼
     Vérification réseau
            │
            ▼
     Mise à jour du système
            │
            ▼
       État de référence
            │
            ▼
        Phase suivante
```

Cette phase ne modifie pas encore les mécanismes de sécurité principaux.

Elle prépare simplement le terrain pour les phases suivantes.

---

# 1. Vérification du système

La première étape consiste à identifier précisément la distribution Linux utilisée.

### Commande

```bash
cat /etc/os-release
```

Cette commande permet notamment d'obtenir :

* le nom de la distribution ;
* la version ;
* l'identifiant du système ;
* les informations relatives à la distribution.

Exemple :

```text
NAME="Ubuntu"
VERSION="24.04 LTS ..."
ID=ubuntu
```

### Pourquoi ?

Les commandes et les fichiers de configuration peuvent varier selon la distribution.

Il est donc important de connaître le système avant d'exécuter un script de durcissement.

---

# 2. Vérification de la version du noyau

Le noyau constitue le cœur du système Linux.

### Commande

```bash
uname -r
```

Pour obtenir davantage d'informations :

```bash
uname -a
```

### Pourquoi ?

Cette vérification permet de connaître :

* la version du noyau ;
* l'architecture ;
* certaines informations sur la plateforme.

Cela peut être utile pour identifier d'éventuelles incompatibilités avec certaines configurations de sécurité.

---

# 3. Vérification de l'utilisateur courant

Avant de modifier les comptes et les privilèges, il faut identifier l'utilisateur actuellement connecté.

### Commande

```bash
whoami
```

Pour obtenir davantage d'informations :

```bash
id
```

### Exemple

```text
uid=1000(abdelwahab) gid=1000(abdelwahab) groups=1000(abdelwahab),27(sudo)
```

La commande `id` permet notamment de vérifier les groupes auxquels appartient l'utilisateur.

### Pourquoi ?

Cette vérification est importante car le reste du projet nécessite généralement un compte disposant de privilèges administratifs via `sudo`.

---

# 4. Vérification des privilèges administratifs

Le projet privilégie l'utilisation de `sudo` plutôt que la connexion permanente avec le compte `root`.

### Commande

```bash
sudo -v
```

Cette commande permet de vérifier que l'utilisateur peut utiliser `sudo`.

Une vérification plus complète peut être réalisée avec :

```bash
sudo -l
```

### Pourquoi ?

Avant d'exécuter les phases de durcissement, il faut s'assurer que le compte utilisé possède les privilèges nécessaires.

Sans accès `sudo`, les opérations suivantes ne pourront pas être correctement réalisées.

---

# 5. Vérification de l'espace disque

Un serveur doit disposer de suffisamment d'espace pour fonctionner correctement.

### Commande

```bash
df -h
```

Cette commande permet de visualiser :

* les systèmes de fichiers ;
* leur taille ;
* l'espace utilisé ;
* l'espace disponible ;
* le pourcentage d'utilisation.

### Vérification ciblée de la partition racine

```bash
df -h /
```

### Pourquoi ?

Certaines opérations du projet vont générer ou modifier des fichiers :

* journaux ;
* bases AIDE ;
* journaux Auditd ;
* fichiers de configuration ;
* paquets.

Un espace disque insuffisant peut provoquer des erreurs ou perturber le fonctionnement du serveur.

---

# 6. Vérification de la mémoire

La mémoire disponible doit également être vérifiée avant de lancer différents outils d'audit.

### Commande

```bash
free -h
```

### Pourquoi ?

Les outils d'audit et les opérations de mise à jour peuvent utiliser des ressources supplémentaires.

Cette vérification permet donc d'avoir une vision générale des ressources disponibles.

---

# 7. Vérification du réseau

Avant de modifier le pare-feu ou SSH, il est important de vérifier que le réseau fonctionne correctement.

### Adresse IP

```bash
ip addr
```

### Routes

```bash
ip route
```

### Résolution DNS

```bash
resolvectl status
```

### Test de connectivité

```bash
ping -c 4 8.8.8.8
```

### Test de résolution DNS

```bash
ping -c 4 google.com
```

### Pourquoi ?

Cette étape permet de distinguer :

* un problème réseau existant avant le durcissement ;
* un problème introduit par une configuration ultérieure.

C'est particulièrement important avant de modifier UFW ou les paramètres réseau du noyau.

---

# 8. Mise à jour du système

Une fois l'état initial vérifié, le système est mis à jour.

### Actualisation des dépôts

```bash
sudo apt update
```

Cette commande actualise la liste des paquets disponibles.

### Mise à jour des paquets

```bash
sudo apt upgrade
```

Pour effectuer la mise à niveau automatiquement :

```bash
sudo apt upgrade -y
```

### Pourquoi ?

Le durcissement doit idéalement être effectué sur un système à jour.

Les mises à jour peuvent notamment apporter :

* des correctifs de sécurité ;
* des corrections de bugs ;
* des améliorations de stabilité ;
* des versions corrigées de certains composants.

---

# 9. Vérification des mises à jour

Après la mise à jour, il est utile de vérifier s'il reste des paquets à mettre à niveau.

### Commande

```bash
apt list --upgradable
```

Si aucun paquet n'est retourné, le système est normalement à jour.

### Vérification du noyau

```bash
uname -r
```

Si une mise à jour du noyau a été installée, un redémarrage peut être nécessaire pour utiliser effectivement le nouveau noyau.

---

# 10. État initial du serveur

Avant de commencer le véritable durcissement, il est recommandé de conserver plusieurs informations concernant l'état initial.

Les commandes suivantes peuvent être utilisées :

```bash
hostnamectl
```

```bash
uptime
```

```bash
ip addr
```

```bash
ip route
```

```bash
ss -tuln
```

```bash
systemctl --type=service --state=running
```

### Ports en écoute

La commande :

```bash
ss -tuln
```

permet d'identifier les ports TCP/UDP actuellement en écoute.

Cette information est particulièrement importante pour la suite du projet car elle permet d'identifier la **surface d'exposition réseau initiale** du serveur.

---

# 11. Vérifications finales

Avant de passer à la phase suivante, plusieurs contrôles doivent être réalisés.

### Système

```bash
cat /etc/os-release
uname -r
```

### Utilisateur

```bash
whoami
id
sudo -v
```

### Ressources

```bash
df -h
free -h
```

### Réseau

```bash
ip addr
ip route
```

### Services et ports

```bash
ss -tuln
```

```bash
systemctl --type=service --state=running
```

---

# 📌 Résultat attendu

À la fin de cette phase, nous devons connaître :

| Élément         | Résultat attendu |
| --------------- | ---------------- |
| Distribution    | Identifiée       |
| Version         | Identifiée       |
| Noyau           | Identifié        |
| Utilisateur     | Identifié        |
| `sudo`          | Fonctionnel      |
| Disque          | Vérifié          |
| Mémoire         | Vérifiée         |
| Réseau          | Fonctionnel      |
| DNS             | Fonctionnel      |
| Système         | Mis à jour       |
| Ports ouverts   | Identifiés       |
| Services actifs | Identifiés       |

Le serveur est alors prêt pour commencer les opérations de durcissement.

---

# ⚠️ Points d'attention

Cette phase doit être réalisée avant toute modification importante.

En particulier, il est recommandé de conserver une trace de l'état initial avant :

* la modification de SSH ;
* l'activation du pare-feu ;
* la modification des paramètres réseau ;
* l'installation des mécanismes de protection.

Ces informations peuvent servir de référence en cas de problème pendant les phases suivantes.

---

# ✅ Conclusion

La Phase 0 constitue la **base du projet de durcissement**.

Elle permet de passer d'un serveur dont l'état est simplement connu de manière approximative à un serveur dont les caractéristiques initiales sont identifiées.

Les informations collectées pendant cette phase serviront de référence pour mesurer les changements apportés lors des phases suivantes.

Le serveur peut maintenant passer à la **Phase 1 — Gestion des utilisateurs et des privilèges**.