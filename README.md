# Linux Server Hardening

![Linux](https://img.shields.io/badge/Linux-Server-FCC624?logo=linux\&logoColor=black)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu\&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Automatisation-4EAA25?logo=gnubash\&logoColor=white)
![SSH](https://img.shields.io/badge/SSH-Sécurisé-222222?logo=openssh\&logoColor=white)
![UFW](https://img.shields.io/badge/UFW-Firewall-CC0000)
![Fail2ban](https://img.shields.io/badge/Fail2ban-Brute--Force-8B0000)
![Lynis](https://img.shields.io/badge/Lynis-Audit-4B0082)
![AIDE](https://img.shields.io/badge/AIDE-Intégrité-006400)
![License](https://img.shields.io/badge/License-MIT-green)

> **Projet de durcissement et de sécurisation d'un serveur Linux avant sa mise en production.**

---

## 📋 Sommaire

* [À propos du projet](#-à-propos-du-projet)
* [Pourquoi durcir un serveur Linux ?](#-pourquoi-durcir-un-serveur-linux-)
* [Objectifs](#-objectifs)
* [Environnement](#-environnement)
* [Architecture du projet](#-architecture-du-projet)
* [Phases du projet](#-phases-du-projet)
* [Prérequis](#-prérequis)
* [Installation et utilisation](#-installation-et-utilisation)
* [Principe d'utilisation des scripts](#-principe-dutilisation-des-scripts)
* [Vérifications de sécurité](#-vérifications-de-sécurité)
* [Bonnes pratiques](#-bonnes-pratiques)
* [Limites du projet](#-limites-du-projet)
* [Perspectives d'évolution](#-perspectives-dévolution)
* [Documentation](#-documentation)
* [Auteur](#-auteur)
* [Licence](#-licence)

---

# 🔐 À propos du projet

Lorsqu'un serveur VPS ou une machine Linux est provisionné, la tendance est souvent de passer directement à l'installation des services nécessaires : serveur Web, Docker, base de données, applications, etc.

Pourtant, un serveur nouvellement installé constitue également une surface d'attaque potentielle.

Le projet **Linux Server Hardening** a pour objectif de mettre en place une démarche structurée de **durcissement d'un serveur Linux avant son utilisation en production**.

L'approche adoptée consiste à réduire progressivement la surface d'attaque du système en appliquant plusieurs mesures de sécurité :

* gestion sécurisée des utilisateurs et privilèges ;
* sécurisation du service SSH ;
* filtrage des connexions réseau ;
* protection contre les attaques par force brute ;
* durcissement du noyau Linux et des paramètres réseau ;
* audit et contrôle de conformité ;
* vérification de l'intégrité des fichiers système ;
* détection de potentiels rootkits.

Le projet a d'abord été réalisé manuellement afin de comprendre et de valider chaque mesure de sécurité, puis les différentes étapes sont progressivement transformées en **scripts Bash réutilisables**.

L'objectif final est de pouvoir reproduire le même processus de sécurisation sur différents serveurs Linux sans devoir reprendre manuellement toutes les commandes.

---

# 🛡️ Pourquoi durcir un serveur Linux ?

Un système Linux correctement installé n'est pas nécessairement un système correctement sécurisé.

Avant de déployer une application ou un service, plusieurs éléments doivent être vérifiés :

```text
Serveur Linux fraîchement installé
            │
            ▼
   Gestion des utilisateurs
            │
            ▼
      Sécurisation SSH
            │
            ▼
     Pare-feu réseau
            │
            ▼
       Fail2ban
            │
            ▼
   Kernel & réseau
            │
            ▼
       Audit sécurité
            │
            ▼
       Vérifications
            │
            ▼
      Serveur durci
            │
            ▼
      Mise en production
```

Cette démarche permet notamment de limiter :

* les accès non autorisés ;
* les tentatives de connexion répétées ;
* l'exposition inutile des services ;
* l'exploitation de configurations faibles ;
* les modifications non autorisées de fichiers sensibles ;
* certaines mauvaises configurations du système.

---

# 🎯 Objectifs

## Objectif principal

Mettre en place une méthodologie reproductible permettant de **durcir un serveur Linux avant son exposition à un réseau ou à Internet**.

## Objectifs secondaires

Le projet vise notamment à :

* appliquer le principe du moindre privilège ;
* sécuriser l'administration distante ;
* réduire la surface d'exposition réseau ;
* protéger les services contre certaines attaques automatisées ;
* renforcer certains paramètres du noyau Linux ;
* surveiller les fichiers et configurations sensibles ;
* réaliser des audits de sécurité ;
* vérifier l'intégrité du système ;
* automatiser progressivement les opérations de durcissement.

---

# 🖥️ Environnement

Le projet a été réalisé sur une machine virtuelle Linux afin de disposer d'un environnement isolé permettant de tester les différentes mesures de sécurité sans modifier directement une infrastructure de production.

### Environnement utilisé

| Élément                | Configuration    |
| ---------------------- | ---------------- |
| Système                | Ubuntu Server    |
| Version                | Ubuntu 24.04 LTS |
| Virtualisation         | VMware           |
| Mémoire                | 2 Go RAM         |
| Stockage               | Disque virtuel   |
| Shell                  | Bash             |
| Accès administratif    | `sudo`           |
| Pare-feu               | UFW              |
| Protection brute force | Fail2ban         |
| Audit                  | Lynis            |
| Audit système          | Auditd           |
| Intégrité              | AIDE             |
| Détection rootkits     | RKHunter         |

L'environnement peut être adapté à d'autres distributions Linux avec les modifications nécessaires au niveau des chemins, paquets et outils utilisés.

---

# 📁 Architecture du projet

Le dépôt est organisé par phases afin de conserver une séparation claire entre les différentes étapes du durcissement.

```text
linux-server-hardening/
│
├── README.md
│
├── phase-0-preparation/
│   ├── README.md
│   └── hardening.sh
│
├── phase-1-utilisateurs-et-privileges/
│   ├── README.md
│   └── hardening.sh
│
├── phase-2/
│   ├── README.md
│   └── hardening.sh
│
├── phase-3-ssh/
│   ├── README.md
│   └── hardening.sh
│
├── phase-4-ufw/
│   ├── README.md
│   └── hardening.sh
│
├── phase-5-fail2ban/
│   ├── README.md
│   └── hardening.sh
│
├── phase-6-kernel-network/
│   ├── README.md
│   └── hardening.sh
│
├── phase-7-audit/
│   ├── README.md
│   ├── auditd/
│   ├── aide/
│   ├── rkhunter/
│   └── lynis/
│
├── scripts/
│   └── ...
│
├── docs/
│   └── ...
│
└── LICENSE
```

> L'arborescence pourra évoluer au fur et à mesure de l'automatisation des différentes phases.

---

# 🧱 Phases du projet

Le durcissement est organisé en plusieurs phases indépendantes.

## Phase 0 — Préparation du serveur

Cette phase prépare le système avant l'application des mesures de sécurité.

Principales opérations :

* vérification du système ;
* mise à jour des paquets ;
* vérification de l'utilisateur courant ;
* vérification des privilèges administratifs ;
* préparation de l'environnement.

📂 [`phase-0-preparation/`](./phase-0-preparation/)

---

## Phase 1 — Gestion des utilisateurs et des privilèges

Cette phase permet de sécuriser la gestion des comptes locaux.

Principales opérations :

* vérification de l'existence d'un utilisateur administratif ;
* création d'un utilisateur si nécessaire ;
* ajout au groupe `sudo` ;
* vérification des privilèges ;
* test de l'accès `sudo` ;
* limitation de l'utilisation directe du compte `root`.

📂 [`phase-1-utilisateurs-et-privileges/`](./phase-1-utilisateurs-et-privileges/)

---

## Phase 2 — Préparation et configuration administrative

Cette phase permet de préparer le système pour les opérations d'administration sécurisée.

Elle constitue une étape intermédiaire avant la sécurisation de l'administration distante avec SSH.

📂 [`phase-2/`](./phase-2/)

---

## Phase 3 — Sécurisation du service SSH

SSH étant l'un des principaux points d'administration distante d'un serveur, cette phase constitue une étape majeure du durcissement.

Les opérations réalisées sont :

1. sauvegarde de la configuration SSH ;
2. mise en place de l'authentification par clé SSH ;
3. désactivation de la connexion `root` à distance ;
4. désactivation de l'authentification par mot de passe ;
5. changement du port SSH ;
6. vérification de la configuration ;
7. redémarrage/rechargement du service SSH ;
8. test de connexion avec la nouvelle configuration.

📂 [`phase-3-ssh/`](./phase-3-ssh/)

> **Important :** la sauvegarde de la configuration est réalisée avant toute modification afin de pouvoir revenir à l'état précédent en cas de problème.

---

## Phase 4 — Pare-feu et filtrage réseau avec UFW

Cette phase permet de contrôler les connexions réseau entrantes et sortantes du serveur.

Principales opérations :

* installation et activation d'UFW ;
* définition de la politique par défaut ;
* autorisation du nouveau port SSH ;
* configuration des règles nécessaires ;
* activation du pare-feu ;
* vérification des règles ;
* vérification de l'état du pare-feu.

Exemple :

```bash
sudo ufw status verbose
```

📂 [`phase-4-ufw/`](./phase-4-ufw/)

---

## Phase 5 — Protection contre les attaques brute force avec Fail2ban

Fail2ban permet de détecter certaines tentatives répétées d'authentification et de bloquer temporairement les adresses IP concernées.

La phase comprend notamment :

* installation de Fail2ban ;
* configuration du service ;
* configuration de la protection SSH ;
* définition des paramètres de bannissement ;
* démarrage et activation du service ;
* vérification de l'état ;
* vérification des jails actives.

Exemple :

```bash
sudo fail2ban-client status
```

📂 [`phase-5-fail2ban/`](./phase-5-fail2ban/)

---

## Phase 6 — Durcissement du noyau Linux et des paramètres réseau

Cette phase vise à réduire certains risques liés au comportement du noyau et de la pile réseau.

Les paramètres sont configurés principalement via :

```text
/etc/sysctl.conf
/etc/sysctl.d/
```

Les mesures peuvent notamment concerner :

* la protection contre certaines attaques réseau ;
* le comportement du routage ;
* la gestion des redirections ICMP ;
* les paramètres IPv4/IPv6 ;
* certains paramètres liés aux connexions réseau ;
* la réduction de certaines possibilités inutiles sur un serveur.

Les modifications sont appliquées avec :

```bash
sudo sysctl --system
```

Puis vérifiées avec :

```bash
sysctl -a
```

📂 [`phase-6-kernel-network/`](./phase-6-kernel-network/)

---

## Phase 7 — Audit de sécurité et contrôle de conformité

La dernière phase du projet regroupe plusieurs outils complémentaires permettant d'évaluer l'état de sécurité du serveur.

### Lynis

Lynis permet d'effectuer un audit de sécurité et de produire un **Hardening Index**.

```bash
sudo lynis audit system
```

Le projet a permis d'améliorer progressivement le score de durcissement obtenu lors des audits.

---

### Auditd

Auditd permet d'enregistrer des événements liés à certaines opérations sensibles du système.

Exemples de fichiers surveillés :

```text
/etc/passwd
/etc/group
/etc/shadow
/etc/gshadow
/etc/sudoers
/etc/sudoers.d
/etc/ssh/sshd_config
/etc/hosts
/etc/network
```

Les règles sont placées dans :

```text
/etc/audit/rules.d/
```

Elles peuvent ensuite être chargées avec :

```bash
sudo augenrules --load
```

Les règles actives peuvent être vérifiées avec :

```bash
sudo auditctl -l
```

Les événements peuvent être recherchés avec :

```bash
sudo ausearch -k identity
sudo ausearch -k sudoers
sudo ausearch -k ssh_config
sudo ausearch -k network
```

---

### AIDE

AIDE permet de vérifier l'intégrité des fichiers du système.

La base initiale est générée avec :

```bash
sudo aideinit
```

Une vérification peut ensuite être effectuée avec :

```bash
sudo aide --config /etc/aide/aide.conf --check
```

AIDE permet notamment d'identifier :

* les fichiers ajoutés ;
* les fichiers supprimés ;
* les fichiers modifiés ;
* les changements de taille ;
* les changements de permissions ;
* les changements de date ;
* les changements d'empreinte cryptographique.

---

### RKHunter

RKHunter est utilisé pour rechercher certains signes caractéristiques de rootkits ou de modifications suspectes.

Exemple :

```bash
sudo rkhunter --check
```

Une mise à jour de ses données peut être réalisée avec :

```bash
sudo rkhunter --update
```

Lors du projet, le contrôle a notamment permis de vérifier :

```text
Files checked     : 142
Suspect files     : 0

Rootkits checked  : 498
Possible rootkits : 0
```

📂 [`phase-7-audit/`](./phase-7-audit/)

---

# ⚙️ Prérequis

Avant d'utiliser les scripts, les conditions suivantes sont recommandées :

* Ubuntu Server 24.04 LTS ;
* accès à un compte disposant de `sudo` ;
* connexion réseau fonctionnelle ;
* accès console disponible en cas de perte de connexion SSH ;
* système sauvegardé avant les modifications critiques ;
* connaissance minimale de Linux et de SSH.

Pour un serveur distant, il est **fortement recommandé de conserver un accès console ou une méthode de récupération hors bande** avant de modifier SSH ou le pare-feu.

---

# 🚀 Installation et utilisation

## 1. Cloner le dépôt

```bash
git clone https://github.com/<UTILISATEUR>/linux-server-hardening.git
```

Puis :

```bash
cd linux-server-hardening
```

---

## 2. Examiner la phase à exécuter

Chaque phase possède son propre README contenant :

* l'objectif ;
* les prérequis ;
* les modifications effectuées ;
* les commandes ;
* les fichiers modifiés ;
* les vérifications ;
* les éventuels points d'attention.

Exemple :

```bash
cd phase-4-ufw
cat README.md
```

---

## 3. Rendre le script exécutable

```bash
chmod +x hardening.sh
```

---

## 4. Exécuter le script

```bash
sudo ./hardening.sh
```

---

## 5. Vérifier le résultat

Chaque script doit effectuer des contrôles après modification.

L'objectif n'est pas simplement d'exécuter des commandes, mais de vérifier que la configuration attendue est réellement appliquée.

---

# 🔁 Principe d'utilisation des scripts

Le projet suit une logique **phase par phase**.

```text
Clone du dépôt
      │
      ▼
Phase 0
Préparation
      │
      ▼
Phase 1
Utilisateurs / sudo
      │
      ▼
Phase 2
Préparation administrative
      │
      ▼
Phase 3
SSH
      │
      ▼
Phase 4
UFW
      │
      ▼
Phase 5
Fail2ban
      │
      ▼
Phase 6
Kernel / Réseau
      │
      ▼
Phase 7
Audit
      │
      ▼
Serveur durci
```

Cette organisation permet de ne pas transformer le projet en un unique script difficile à maintenir.

Chaque phase peut être :

* étudiée séparément ;
* exécutée séparément ;
* vérifiée séparément ;
* adaptée à un environnement particulier.

---

# 🔍 Vérifications de sécurité

Après le durcissement, plusieurs vérifications peuvent être réalisées.

### SSH

```bash
sudo sshd -t
sudo systemctl status ssh
```

### UFW

```bash
sudo ufw status verbose
```

### Fail2ban

```bash
sudo systemctl status fail2ban
sudo fail2ban-client status
```

### Auditd

```bash
sudo systemctl status auditd
sudo auditctl -l
```

### AIDE

```bash
sudo aide --config /etc/aide/aide.conf --check
```

### RKHunter

```bash
sudo rkhunter --check
```

### Lynis

```bash
sudo lynis audit system
```

---

# ⚠️ Bonnes pratiques

Le durcissement d'un serveur doit être réalisé progressivement.

Avant toute modification critique :

1. sauvegarder la configuration ;
2. vérifier la syntaxe ;
3. appliquer la modification ;
4. vérifier le service ;
5. tester la fonctionnalité ;
6. conserver une méthode de récupération.

Une attention particulière doit être portée aux modifications concernant :

* SSH ;
* UFW ;
* le réseau ;
* les paramètres du noyau ;
* les comptes administrateurs.

Une erreur de configuration sur l'un de ces composants peut rendre un serveur distant inaccessible.

---

# 📊 Résultats obtenus

À l'issue du projet, plusieurs mécanismes de sécurité ont été mis en place :

| Domaine      | Mesure                                       |
| ------------ | -------------------------------------------- |
| Comptes      | Utilisateur administratif + sudo             |
| SSH          | Authentification par clé                     |
| SSH          | Root distant désactivé                       |
| SSH          | Authentification par mot de passe désactivée |
| SSH          | Port personnalisé                            |
| Réseau       | UFW                                          |
| Brute force  | Fail2ban                                     |
| Kernel       | Paramètres sysctl                            |
| Audit        | Auditd                                       |
| Intégrité    | AIDE                                         |
| Rootkits     | RKHunter                                     |
| Audit global | Lynis                                        |

Le score Lynis obtenu au cours du projet a atteint :

```text
Hardening Index : 74
Tests performed : 267
```

Ce score constitue un indicateur de progression et non une garantie absolue de sécurité.

---

# 🚧 Limites du projet

Ce projet constitue une base de durcissement généraliste et ne remplace pas une analyse de sécurité adaptée à chaque infrastructure.

Les configurations peuvent varier selon :

* la distribution Linux ;
* les services installés ;
* le rôle du serveur ;
* l'architecture réseau ;
* les exigences de sécurité ;
* les contraintes métier.

Certaines recommandations de Lynis peuvent également nécessiter une analyse avant application afin d'éviter de casser une fonctionnalité nécessaire au serveur.

---

# 🔮 Perspectives d'évolution

Plusieurs évolutions sont envisagées pour transformer progressivement ce projet en véritable outil de déploiement de serveurs sécurisés.

### 1. Automatisation complète avec Ansible

Transformer les scripts Bash en rôles Ansible permettant d'appliquer le durcissement de manière idempotente sur plusieurs serveurs.

```text
Ansible Controller
       │
       ├── Serveur Web
       ├── Serveur API
       ├── Serveur BDD
       └── Serveur Docker
```

### 2. Intégration dans un pipeline CI/CD

Ajouter des contrôles automatisés permettant de vérifier les scripts avant leur déploiement.

Exemples :

* ShellCheck ;
* tests automatisés ;
* validation des configurations ;
* analyse de sécurité.

### 3. Centralisation de la supervision et des logs

Faire évoluer la partie audit vers une architecture centralisée avec des solutions telles que :

* Wazuh ;
* SIEM ;
* centralisation des journaux ;
* alertes de sécurité ;
* tableaux de bord.

### 4. Création d'un profil de durcissement

Créer plusieurs profils adaptés aux rôles des serveurs :

```text
profiles/
├── base/
├── web-server/
├── docker-server/
├── database-server/
└── bastion/
```

Cela permettrait d'éviter d'appliquer exactement les mêmes règles à tous les serveurs.

---

# 📚 Documentation

La documentation détaillée du projet est disponible dans les différents répertoires de phases.

Chaque phase contient sa propre documentation afin de permettre une compréhension complète des opérations réalisées.

Une documentation PDF complète peut également être générée à partir du projet pour présenter :

* le contexte ;
* l'environnement ;
* les objectifs ;
* les différentes phases ;
* les configurations ;
* les résultats ;
* les audits ;
* les perspectives.

---

# 👨‍💻 Auteur

**Abdelwahab Abdourahamane**

Projet personnel de **Linux Server Hardening** orienté :

* Administration Linux ;
* Cybersécurité ;
* Infrastructure ;
* DevSecOps ;
* Sécurité des serveurs.

---

# 📄 Licence

Ce projet est distribué sous licence **MIT**.

Vous êtes libre de :

* utiliser le projet ;
* modifier les scripts ;
* adapter les configurations ;
* redistribuer le projet ;

sous réserve du respect des conditions définies dans le fichier [`LICENSE`](./LICENSE).

---

## ⭐ Contribution

Les suggestions d'amélioration sont les bienvenues.

Si ce projet vous est utile, n'hésitez pas à :

* ⭐ mettre une étoile au dépôt ;
* ouvrir une issue ;
* proposer une amélioration ;
* partager le projet.

---

> **Objectif du projet : ne pas simplement installer un serveur, mais le sécuriser avant de lui confier des services.**
