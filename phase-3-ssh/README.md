# Phase 3 — Sécurisation de l'accès SSH

## 1. Objectif

SSH (Secure Shell) est le principal mécanisme permettant d'administrer un serveur Linux à distance.

Une configuration SSH par défaut peut cependant présenter plusieurs risques, notamment lorsque l'authentification par mot de passe ou la connexion directe du compte `root` sont autorisées.

L'objectif de cette phase est donc de mettre en place une administration distante sécurisée avant de poursuivre le durcissement du serveur.

La phase suit l'ordre réellement utilisé lors du projet :

1. Installation d'OpenSSH ;
2. Vérification du service SSH ;
3. Sauvegarde de la configuration SSH ;
4. Mise en place de l'authentification par clé SSH ;
5. Test de l'accès SSH par clé ;
6. Désactivation de la connexion root SSH ;
7. Désactivation de l'authentification par mot de passe ;
8. Changement du port SSH ;
9. Vérification de la configuration SSH ;
10. Redémarrage/rechargement du service ;
11. Test final de connexion.

> **Important :** les modifications SSH sont appliquées progressivement afin d'éviter de perdre l'accès au serveur.

---

# 2. Installation d'OpenSSH

Si SSH n'est pas encore installé sur le serveur, la première étape consiste à installer le serveur OpenSSH.

Sur un système Debian ou dérivé utilisant APT :

```bash
sudo apt update
sudo apt install openssh-server -y
```

Le paquet `openssh-server` fournit le service SSH permettant aux clients distants de se connecter au serveur.

---

# 3. Vérification de l'installation

Après l'installation, vérifier que le service SSH est présent :

```bash
systemctl status ssh
```

Le résultat attendu est similaire à :

```text
Active: active (running)
```

Le démarrage automatique du service est également vérifié :

```bash
systemctl is-enabled ssh
```

Si nécessaire :

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

---

# 4. Vérification du port SSH

Avant toute modification, il est important d'identifier le port actuellement utilisé par SSH.

```bash
sudo ss -tlnp | grep ssh
```

Par défaut, SSH écoute généralement sur :

```text
22/tcp
```

Cette information sera utilisée plus tard lors du changement du port SSH.

---

# 5. Sauvegarde de la configuration SSH

Avant toute modification de la configuration, une copie du fichier original est réalisée.

Le fichier principal est :

```text
/etc/ssh/sshd_config
```

Création d'une sauvegarde :

```bash
sudo cp /etc/ssh/sshd_config \
/var/backups/linux-server-hardening/sshd_config.backup
```

Vérification :

```bash
ls -l /var/backups/linux-server-hardening/
```

Cette sauvegarde permet de revenir à la configuration précédente en cas de problème.

---

# 6. Mise en place de l'authentification par clé SSH

L'authentification par clé SSH permet d'éviter l'utilisation du mot de passe pour l'administration distante.

La paire de clés est générée sur la machine cliente.

```bash
ssh-keygen -t ed25519
```

La clé privée est conservée sur le poste client.

La clé publique doit être installée sur le serveur dans :

```text
~/.ssh/authorized_keys
```

Une méthode simple consiste à utiliser :

```bash
ssh-copy-id utilisateur@adresse_ip_du_serveur
```

Exemple :

```bash
ssh-copy-id abdelwahab@192.168.1.100
```

---

# 7. Vérification de la clé publique

Sur le serveur :

```bash
ls -la ~/.ssh/
```

Puis :

```bash
cat ~/.ssh/authorized_keys
```

Le fichier doit contenir la clé publique du poste client.

Les permissions du répertoire et du fichier sont ensuite vérifiées :

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

# 8. Test de l'authentification par clé

Avant de désactiver l'authentification par mot de passe, il est obligatoire de vérifier que l'accès par clé fonctionne.

Depuis le poste client :

```bash
ssh utilisateur@adresse_ip_du_serveur
```

Si le serveur utilise encore le port 22 :

```bash
ssh -p 22 utilisateur@adresse_ip_du_serveur
```

La connexion doit être possible sans demander le mot de passe du compte Linux.

> **Ne jamais désactiver l'authentification par mot de passe avant d'avoir confirmé que l'authentification par clé fonctionne.**

---

# 9. Désactivation de la connexion root SSH

Une fois l'accès administrateur par clé fonctionnel, la connexion directe du compte `root` est désactivée.

Modifier :

```bash
sudo nano /etc/ssh/sshd_config
```

Configurer :

```text
PermitRootLogin no
```

Cette configuration empêche une connexion SSH directe avec le compte `root`.

L'administration continue à être effectuée avec un compte utilisateur disposant de `sudo`.

---

# 10. Désactivation de l'authentification par mot de passe

Une fois l'authentification par clé testée avec succès, l'authentification SSH par mot de passe peut être désactivée.

Dans :

```text
/etc/ssh/sshd_config
```

Configurer :

```text
PasswordAuthentication no
```

Il est également recommandé de vérifier :

```text
PubkeyAuthentication yes
```

La configuration obtenue permet alors d'utiliser l'authentification par clé publique.

---

# 11. Changement du port SSH

Le port SSH par défaut `22` est fréquemment ciblé par les scans automatisés.

Dans le cadre de ce projet, le port SSH est modifié.

Dans :

```text
/etc/ssh/sshd_config
```

Configurer par exemple :

```text
Port 2222
```

> Le numéro `2222` est un exemple. Le projet peut utiliser un autre port non utilisé sur le serveur.

Avant de choisir le nouveau port, vérifier qu'il n'est pas déjà utilisé :

```bash
sudo ss -tulpn | grep 2222
```

Si aucune sortie n'est retournée, le port est normalement disponible.

---

# 12. Vérification de la configuration SSH

Avant de redémarrer ou recharger SSH, la configuration doit impérativement être testée.

Commande :

```bash
sudo sshd -t
```

Si aucune sortie n'est affichée, la syntaxe de la configuration est correcte.

Cette étape est essentielle.

Une erreur dans `sshd_config` pourrait empêcher le service SSH de redémarrer correctement.

---

# 13. Vérification de la configuration effective

Pour examiner la configuration SSH effectivement appliquée :

```bash
sudo sshd -T
```

Il est possible de filtrer les paramètres importants :

```bash
sudo sshd -T | grep -E \
'port|permitrootlogin|passwordauthentication|pubkeyauthentication'
```

Le résultat doit notamment contenir :

```text
port 2222
permitrootlogin no
passwordauthentication no
pubkeyauthentication yes
```

---

# 14. Rechargement du service SSH

Après validation de la configuration :

```bash
sudo systemctl reload ssh
```

Le rechargement permet d'appliquer la nouvelle configuration sans interrompre inutilement les connexions existantes.

En cas de nécessité :

```bash
sudo systemctl restart ssh
```

---

# 15. Vérification du nouveau port

Après le rechargement :

```bash
sudo ss -tlnp | grep ssh
```

Le serveur doit maintenant écouter sur le nouveau port.

Exemple :

```text
LISTEN 0 128 0.0.0.0:2222
LISTEN 0 128 [::]:2222
```

---

# 16. Test final de connexion SSH

Depuis le poste client :

```bash
ssh -p 2222 utilisateur@adresse_ip_du_serveur
```

La connexion doit :

* utiliser le nouveau port ;
* utiliser la clé SSH ;
* ne pas utiliser l'authentification par mot de passe ;
* ne pas permettre la connexion directe avec `root`.

---

# 17. Vérification de l'accès sudo après connexion

Une fois connecté avec le compte utilisateur :

```bash
whoami
```

Puis :

```bash
sudo -v
```

Et :

```bash
sudo id
```

Le résultat doit confirmer que l'utilisateur possède toujours les privilèges administratifs via `sudo`.

---

# 18. Restauration en cas de problème

Si une erreur de configuration empêche SSH de fonctionner, la sauvegarde créée au début de la phase peut être restaurée.

```bash
sudo cp \
/var/backups/linux-server-hardening/sshd_config.backup \
/etc/ssh/sshd_config
```

Puis vérifier :

```bash
sudo sshd -t
```

Et redémarrer SSH :

```bash
sudo systemctl restart ssh
```

---

# 19. Résultat attendu

À la fin de cette phase, le serveur dispose d'un accès SSH renforcé :

| Mesure                                | État |
| ------------------------------------- | ---- |
| OpenSSH installé                      | ✅    |
| Service SSH actif                     | ✅    |
| Configuration sauvegardée             | ✅    |
| Authentification par clé              | ✅    |
| Connexion root SSH                    | ❌    |
| Authentification par mot de passe     | ❌    |
| Port SSH par défaut                   | ❌    |
| Nouveau port SSH                      | ✅    |
| Configuration vérifiée avec `sshd -t` | ✅    |
| Connexion finale testée               | ✅    |

Le serveur est maintenant prêt pour la phase suivante : **mise en place du pare-feu et filtrage réseau avec UFW**.

---

## 20. Commandes principales

Installation :

```bash
sudo apt update
sudo apt install openssh-server
```

Service :

```bash
systemctl status ssh
systemctl is-enabled ssh
```

Sauvegarde :

```bash
sudo cp /etc/ssh/sshd_config \
/var/backups/linux-server-hardening/sshd_config.backup
```

Clé SSH :

```bash
ssh-keygen -t ed25519
ssh-copy-id utilisateur@adresse_ip_du_serveur
```

Vérification :

```bash
sudo sshd -t
sudo sshd -T
sudo ss -tlnp | grep ssh
```

Service :

```bash
sudo systemctl reload ssh
```

Connexion finale :

```bash
ssh -p 2222 utilisateur@adresse_ip_du_serveur
```
