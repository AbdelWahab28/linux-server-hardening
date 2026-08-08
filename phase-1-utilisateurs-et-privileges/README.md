# Phase 1 — Gestion des comptes et des privilèges

## 1. Objectif

La gestion des comptes constitue une étape fondamentale du durcissement d'un serveur Linux.

L'objectif de cette phase est de s'assurer que :

* un compte utilisateur administratif existe ;
* les opérations d'administration ne sont pas réalisées quotidiennement avec le compte `root` ;
* l'utilisateur administratif dispose uniquement des privilèges nécessaires ;
* le mécanisme `sudo` est correctement configuré ;
* l'accès aux privilèges administratifs fonctionne avant de poursuivre le durcissement du serveur.

> **Important :** la configuration de SSH n'est pas réalisée dans cette phase. La création et la configuration de l'accès SSH sécurisé sont traitées dans la **Phase 3**.

---

## 2. Pourquoi ne pas travailler directement avec `root` ?

Le compte `root` possède des privilèges complets sur le système.

Une erreur exécutée avec ce compte peut avoir des conséquences importantes, par exemple :

* suppression accidentelle de fichiers système ;
* modification de fichiers critiques ;
* modification de la configuration réseau ;
* arrêt de services ;
* modification des permissions ;
* compromission complète du serveur en cas de vol des identifiants.

L'utilisation d'un compte utilisateur avec `sudo` permet de limiter l'utilisation directe du compte `root`.

Par exemple :

```bash
sudo systemctl restart nginx
```

L'utilisateur travaille normalement avec son compte personnel et élève temporairement ses privilèges uniquement lorsqu'une opération administrative le nécessite.

---

# 3. Vérification de l'utilisateur courant

La première étape consiste à identifier l'utilisateur actuellement connecté.

```bash
whoami
```

Puis à vérifier ses groupes :

```bash
groups
```

On peut également afficher les informations détaillées du compte :

```bash
id
```

Exemple :

```text
uid=1000(abdelwahab) gid=1000(abdelwahab) groups=1000(abdelwahab),27(sudo)
```

La présence du groupe `sudo` indique que l'utilisateur peut utiliser `sudo`.

---

# 4. Vérification du compte root

Le compte `root` doit exister sur un système Linux, mais son utilisation quotidienne doit être évitée.

Vérification :

```bash
id root
```

Exemple :

```text
uid=0(root) gid=0(root) groups=0(root)
```

Cette vérification permet de confirmer la présence du compte administrateur système.

> La désactivation de l'accès distant de `root` sera effectuée plus tard dans la Phase 3, lors du durcissement de SSH.

---

# 5. Vérification du groupe sudo

Sur les systèmes Debian et dérivés, les utilisateurs administrateurs sont généralement ajoutés au groupe `sudo`.

Vérification :

```bash
getent group sudo
```

Exemple :

```text
sudo:x:27:abdelwahab
```

On peut également vérifier directement les groupes de l'utilisateur :

```bash
groups abdelwahab
```

---

# 6. Création d'un compte administratif

Si aucun compte utilisateur administratif n'existe, il faut en créer un avant de poursuivre le durcissement.

Création :

```bash
sudo adduser admin
```

Le système demande alors :

* un mot de passe ;
* le nom complet ;
* différentes informations facultatives.

Les informations personnelles peuvent être laissées vides si elles ne sont pas nécessaires.

---

# 7. Ajout de l'utilisateur au groupe sudo

Une fois le compte créé, il est ajouté au groupe `sudo` :

```bash
sudo usermod -aG sudo admin
```

L'option `-aG` signifie :

* `-a` : ajouter sans supprimer les groupes existants ;
* `-G` : spécifier le ou les groupes supplémentaires.

Il est important d'utiliser `-aG` plutôt que simplement `-G`, car l'utilisation incorrecte de `-G` peut remplacer les groupes secondaires existants de l'utilisateur.

---

# 8. Vérification de l'appartenance au groupe sudo

Après l'ajout :

```bash
groups admin
```

ou :

```bash
id admin
```

On doit retrouver le groupe `sudo`.

Exemple :

```text
uid=1001(admin) gid=1001(admin) groups=1001(admin),27(sudo)
```

---

# 9. Prise en compte du nouveau groupe

Les groupes d'un utilisateur sont chargés lors de l'ouverture de sa session.

Après avoir ajouté l'utilisateur au groupe `sudo`, il est donc recommandé de fermer puis de rouvrir la session.

On peut également utiliser :

```bash
su - admin
```

Puis vérifier :

```bash
groups
```

---

# 10. Test de l'accès sudo

Le fonctionnement de `sudo` doit être vérifié avant de continuer le projet.

Depuis le compte administratif :

```bash
sudo -v
```

Puis :

```bash
sudo whoami
```

Le résultat attendu est :

```text
root
```

Cela confirme que l'utilisateur possède bien les privilèges administratifs via `sudo`.

Un autre test possible :

```bash
sudo id
```

Le résultat doit indiquer :

```text
uid=0(root)
```

---

# 11. Vérification de la configuration sudo

On peut également vérifier que la configuration de `sudo` ne contient pas d'erreur de syntaxe :

```bash
sudo visudo -c
```

Résultat attendu :

```text
/etc/sudoers: parsed OK
```

Cette vérification permet de détecter une erreur dans le fichier `/etc/sudoers` avant de poursuivre le projet.

---

# 12. Principe de moindre privilège

Cette phase applique le principe de **moindre privilège**.

L'utilisateur travaille avec un compte normal et utilise `sudo` uniquement lorsqu'une opération administrative est nécessaire.

Architecture obtenue :

```text
                    SERVEUR LINUX
                         │
          ┌──────────────┴──────────────┐
          │                             │
      root (UID 0)              utilisateur admin
                                      │
                                      │ sudo
                                      ▼
                                   root
```

Le compte utilisateur devient ainsi le compte utilisé pour les opérations quotidiennes et administratives.

---

# 13. Ce qui n'est volontairement pas réalisé dans cette phase

Les éléments suivants sont volontairement exclus de cette phase :

* désactivation de la connexion SSH de `root` ;
* désactivation de l'authentification SSH par mot de passe ;
* authentification SSH par clé ;
* changement du port SSH ;
* configuration du serveur SSH.

Ces opérations seront réalisées dans :

**Phase 3 — Durcissement du service SSH**

---

# 14. Résultat attendu

À la fin de cette phase :

* un utilisateur administratif existe ;
* l'utilisateur n'est pas utilisé comme `root` ;
* l'utilisateur appartient au groupe `sudo` ;
* `sudo` fonctionne correctement ;
* la configuration `sudo` est valide ;
* le serveur est prêt pour la sécurisation de SSH dans la phase suivante.

---

# 15. Commandes principales utilisées

```bash
whoami
id
groups
id root
getent group sudo

sudo adduser admin
sudo usermod -aG sudo admin

su - admin

sudo -v
sudo whoami
sudo id

sudo visudo -c
```

---

# 16. Script d'automatisation

Le fichier `hardening.sh` automatise les opérations principales de cette phase.

Utilisation :

```bash
chmod +x hardening.sh
sudo ./hardening.sh
```

Le script demande le nom du compte administratif à créer ou à utiliser.

> Le script ne modifie volontairement aucune configuration SSH. Cette responsabilité appartient à la Phase 3.
