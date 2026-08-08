# Phase 1 — Gestion des comptes et des privilèges

## 1. Objectif

Cette phase a pour objectif de sécuriser la gestion des comptes utilisateurs et des privilèges administratifs du serveur.

L'objectif principal est d'éviter l'utilisation permanente du compte `root` et de mettre en place un compte utilisateur normal disposant de privilèges administratifs via `sudo`.

Cette étape est particulièrement importante lorsqu'un serveur vient d'être installé et qu'aucun utilisateur administrateur n'a encore été créé.

Le principe appliqué est celui du **moindre privilège** : un utilisateur doit disposer uniquement des privilèges nécessaires à l'administration du système.

---

## 2. Prérequis

Cette phase nécessite :

- un accès local ou console au serveur ;
- un accès au compte `root` ou à un compte disposant déjà de `sudo` ;
- une distribution Linux basée sur Debian ;
- le paquet `sudo` installé.

Vérification :

```bash
sudo --version
```

---

## 3. Vérification des utilisateurs existants

Avant de créer ou modifier un compte, il est nécessaire d'identifier les utilisateurs présents sur le système.

### Liste des utilisateurs

```bash
cat /etc/passwd
```

Le fichier `/etc/passwd` contient les informations relatives aux comptes locaux du système.

Pour identifier principalement les comptes utilisateurs classiques :

```bash
awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd
```

### Vérification des groupes

```bash
cat /etc/group
```

Le groupe `sudo` est particulièrement important puisqu'il permet aux utilisateurs membres d'exécuter des commandes avec des privilèges administratifs.

Vérification :

```bash
getent group sudo
```

---

## 4. Création du compte administrateur

Si aucun compte administrateur normal n'existe, un compte dédié doit être créé.

Exemple :

```bash
sudo adduser admin
```

Le système demande alors un mot de passe ainsi que quelques informations complémentaires.

Les informations facultatives peuvent être laissées vides.

### Pourquoi créer un compte normal ?

L'objectif n'est pas de remplacer `root` par un autre compte ayant directement tous les privilèges.

Le compte créé reste un utilisateur normal et utilise `sudo` uniquement lorsqu'une opération administrative est nécessaire.

---

## 5. Ajouter l'utilisateur au groupe sudo

Une fois le compte créé, il est ajouté au groupe `sudo` :

```bash
sudo usermod -aG sudo admin
```

Vérification :

```bash
groups admin
```

ou :

```bash
id admin
```

Le groupe `sudo` doit apparaître dans la liste.

Exemple :

```text
uid=1000(admin) gid=1000(admin) groups=1000(admin),27(sudo)
```

---

## 6. Vérification des privilèges

Une nouvelle session doit être ouverte après l'ajout de l'utilisateur au groupe `sudo`.

Après reconnexion :

```bash
groups
```

Puis :

```bash
sudo -l
```

Cette commande permet d'afficher les privilèges `sudo` accordés à l'utilisateur.

---

## 7. Test de sudo

Pour vérifier que l'utilisateur peut effectivement obtenir des privilèges administratifs :

```bash
sudo whoami
```

Résultat attendu :

```text
root
```

Cela confirme que `sudo` fonctionne correctement.

L'utilisateur reste néanmoins connecté avec son compte normal.

Vérification :

```bash
whoami
```

Le résultat doit être le nom de l'utilisateur et non `root`.

---

## 8. Vérification de la configuration sudo

La configuration de `sudo` se trouve principalement dans :

```text
/etc/sudoers
```

La syntaxe peut être vérifiée avec :

```bash
sudo visudo -c
```

Résultat attendu :

```text
/etc/sudoers: parsed OK
```

L'utilisation de `visudo` est recommandée pour toute modification du fichier `/etc/sudoers`, car une erreur de syntaxe peut empêcher l'utilisation de `sudo`.

---

## 9. Principe du moindre privilège

La configuration mise en place respecte le principe du moindre privilège.

L'utilisateur :

- n'est pas connecté directement en tant que `root` ;
- possède son propre compte ;
- utilise `sudo` lorsqu'une opération administrative est nécessaire ;
- conserve une traçabilité des commandes administratives exécutées via `sudo`.

Le fonctionnement peut être représenté ainsi :

```text
Utilisateur normal
       |
       | sudo
       v
Privilèges administrateur
       |
       v
     root
```

---

## 10. Vérifications finales

Avant de passer à la phase suivante, les vérifications suivantes doivent être validées :

```bash
whoami
id
groups
sudo -l
sudo whoami
sudo visudo -c
```

Résultats attendus :

- [OK] Un compte utilisateur normal existe
- [OK] Le compte appartient au groupe `sudo`
- [OK] `sudo` fonctionne
- [OK] L'utilisateur n'est pas connecté en tant que `root`
- [OK] La configuration `sudo` est valide

---

## 11. Automatisation

Le fichier `hardening.sh` automatise les opérations nécessaires à cette phase.

Exécution :

```bash
chmod +x hardening.sh
```

Puis :

```bash
sudo ./hardening.sh
```

Le script vérifie d'abord l'environnement puis demande le nom du compte à créer.

Il évite de recréer un utilisateur qui existe déjà.

---

## 12. Résultat de la phase

À la fin de cette phase, le serveur dispose d'un compte utilisateur normal pouvant effectuer les opérations administratives via `sudo`.

Aucune modification de la configuration SSH n'est effectuée durant cette phase.

Le durcissement de SSH sera réalisé dans la phase suivante.
