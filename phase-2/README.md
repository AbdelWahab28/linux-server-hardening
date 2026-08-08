# Phase 2 — Préparation et configuration administrative

## 1. Objectif

La Phase 2 prépare le système Linux pour les opérations d’administration sécurisée.

Contrairement à la Phase 0, qui avait pour objectif d'effectuer un état des lieux général du serveur, cette phase commence à appliquer des mesures de configuration destinées à réduire les risques liés aux opérations administratives.

Elle constitue une étape intermédiaire avant la mise en place de l'administration distante sécurisée avec SSH dans la Phase 3.

### Objectifs de la phase

Cette phase permet de :

* vérifier que le compte administrateur dispose correctement de `sudo` ;
* vérifier l'identité et les privilèges du compte utilisé ;
* renforcer le comportement par défaut des permissions lors de la création de fichiers ;
* limiter la durée de conservation des privilèges `sudo` ;
* sécuriser les permissions de certains fichiers administratifs ;
* préparer un espace de sauvegarde pour les fichiers de configuration qui seront modifiés lors des phases suivantes.

---

# 2. Prérequis

Le script doit être exécuté avec un compte disposant de privilèges `sudo`.

Vérifier l'identité du compte :

```bash
whoami
```

Vérifier les privilèges sudo :

```bash
sudo -v
```

Vérifier les groupes du compte :

```bash
id
```

Le compte utilisé doit être membre du groupe administratif approprié, généralement `sudo` sur les systèmes Debian.

---

# 3. Vérification de l'accès administratif

Avant d'appliquer des modifications, le script vérifie que le compte courant peut utiliser `sudo`.

Commande utilisée :

```bash
sudo -v
```

Cette commande permet de valider les privilèges administrateur sans exécuter directement une opération système.

Le script arrête son exécution si l'utilisateur ne dispose pas des privilèges nécessaires.

---

# 4. Vérification de l'identité administrative

Le compte utilisé pour effectuer le durcissement est identifié avec :

```bash
whoami
```

Puis ses informations sont vérifiées avec :

```bash
id
```

Cela permet notamment de confirmer les groupes auxquels appartient l'utilisateur.

Exemple :

```text
uid=1000(abdelwahab) gid=1000(abdelwahab) groups=1000(abdelwahab),27(sudo)
```

La présence du groupe `sudo` confirme que le compte peut effectuer des opérations administratives.

---

# 5. Configuration du umask

Le `umask` définit les permissions par défaut retirées lors de la création de nouveaux fichiers et répertoires.

Un `umask` trop permissif peut entraîner la création de fichiers accessibles à d'autres utilisateurs du système.

Le projet utilise :

```text
027
```

Ce réglage permet notamment d'éviter que les nouveaux fichiers soient automatiquement accessibles en écriture ou en lecture à tous les utilisateurs.

La configuration est ajoutée dans :

```text
/etc/profile.d/hardening-umask.sh
```

Le fichier contient :

```bash
umask 027
```

Permissions appliquées au fichier :

```bash
chmod 644 /etc/profile.d/hardening-umask.sh
```

> Cette configuration s'applique aux nouvelles sessions utilisateur.

Pour vérifier le comportement après ouverture d'une nouvelle session :

```bash
umask
```

Le résultat attendu est :

```text
0027
```

---

# 6. Réduction de la durée de conservation des privilèges sudo

Par défaut, `sudo` conserve temporairement l'authentification de l'utilisateur.

Dans le cadre du durcissement, cette durée peut être réduite afin de limiter la fenêtre pendant laquelle une session déjà authentifiée peut réutiliser les privilèges administrateur sans demander à nouveau le mot de passe.

Une configuration dédiée est créée dans :

```text
/etc/sudoers.d/hardening
```

Avec :

```text
Defaults timestamp_timeout=5
```

La valeur `5` correspond à cinq minutes.

Après cette période, une nouvelle authentification sera nécessaire pour utiliser à nouveau `sudo`.

La syntaxe du fichier est vérifiée avant toute utilisation :

```bash
visudo -cf /etc/sudoers.d/hardening
```

Il est important de toujours utiliser `visudo` pour vérifier une configuration sudo afin d'éviter de rendre le système inutilisable à cause d'une erreur de syntaxe.

---

# 7. Sécurisation des fichiers administratifs

Certains fichiers contenant des informations relatives aux comptes et aux privilèges doivent conserver des permissions strictes.

Le script vérifie notamment :

```bash
ls -l /etc/passwd
ls -l /etc/group
ls -l /etc/shadow
ls -l /etc/gshadow
```

Les fichiers contenant les informations sensibles d'authentification doivent rester accessibles uniquement aux comptes autorisés.

Le script applique les permissions appropriées lorsque nécessaire :

```bash
chmod 644 /etc/passwd
chmod 644 /etc/group
chmod 640 /etc/shadow
chmod 640 /etc/gshadow
```

Les propriétaires sont également vérifiés :

```bash
chown root:root /etc/passwd
chown root:root /etc/group
chown root:shadow /etc/shadow
chown root:shadow /etc/gshadow
```

> Les permissions exactes peuvent varier selon la distribution Debian utilisée. Le script évite donc de modifier inutilement les fichiers lorsque leur configuration est déjà correcte.

---

# 8. Préparation d'un espace de sauvegarde

Les phases suivantes vont modifier plusieurs fichiers de configuration importants.

Avant toute modification, il est préférable de conserver une copie des fichiers concernés.

Le projet prépare donc :

```text
/var/backups/linux-server-hardening/
```

Création du répertoire :

```bash
sudo mkdir -p /var/backups/linux-server-hardening
```

Protection du répertoire :

```bash
sudo chmod 700 /var/backups/linux-server-hardening
```

Propriétaire :

```bash
sudo chown root:root /var/backups/linux-server-hardening
```

Les phases suivantes pourront utiliser cet emplacement pour sauvegarder leurs fichiers avant modification.

---

# 9. Vérification de la configuration sudo

Après création de la configuration, une vérification est effectuée :

```bash
sudo visudo -cf /etc/sudoers
```

Puis :

```bash
sudo visudo -cf /etc/sudoers.d/hardening
```

Le résultat attendu est similaire à :

```text
/etc/sudoers: parsed OK
/etc/sudoers.d/hardening: parsed OK
```

Cette vérification est importante car une erreur dans `sudoers` peut empêcher l'utilisation normale de `sudo`.

---

# 10. Vérification finale

À la fin de la phase, les principaux éléments sont vérifiés.

### Utilisateur courant

```bash
whoami
```

### Groupes

```bash
id
```

### Umask

```bash
umask
```

### Configuration sudo

```bash
sudo visudo -cf /etc/sudoers
```

### Configuration du durcissement sudo

```bash
sudo visudo -cf /etc/sudoers.d/hardening
```

### Répertoire de sauvegarde

```bash
ls -ld /var/backups/linux-server-hardening
```

---

# 11. Résultat attendu

À la fin de cette phase :

* le compte d'administration possède un accès `sudo` fonctionnel ;
* le comportement de création des fichiers est plus restrictif ;
* la durée de conservation des privilèges `sudo` est réduite ;
* les fichiers sensibles liés aux comptes possèdent des permissions appropriées ;
* un espace protégé est disponible pour les sauvegardes de configuration ;
* la configuration `sudo` a été vérifiée avant de poursuivre.

La machine est maintenant préparée pour la phase suivante : **sécurisation de l'administration distante avec SSH**.

---

## 12. Commandes principales utilisées

```bash
whoami
id
sudo -v
umask
sudo mkdir -p /var/backups/linux-server-hardening
sudo chmod 700 /var/backups/linux-server-hardening
sudo chown root:root /var/backups/linux-server-hardening

sudo visudo -cf /etc/sudoers
sudo visudo -cf /etc/sudoers.d/hardening
```

Permissions des fichiers sensibles :

```bash
sudo chmod 644 /etc/passwd
sudo chmod 644 /etc/group
sudo chmod 640 /etc/shadow
sudo chmod 640 /etc/gshadow
```

---

## 13. Suite du projet

La Phase 2 prépare l'environnement administratif sans encore modifier le service SSH.

La phase suivante sera consacrée à :

**Phase 3 — Sécurisation de l'accès SSH**

Elle comprendra notamment :

* sauvegarde de la configuration SSH ;
* mise en place de l'authentification par clé SSH ;
* désactivation de la connexion root distante ;
* désactivation de l'authentification par mot de passe ;
* changement du port SSH ;
* vérification de la configuration ;
* test de la connexion SSH.