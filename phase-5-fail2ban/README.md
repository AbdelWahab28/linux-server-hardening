# Phase 5 — Protection contre les attaques par force brute avec Fail2ban

## Objectif

Cette phase consiste à mettre en place **Fail2ban** afin de protéger le serveur contre les tentatives répétées de connexion susceptibles de correspondre à une attaque par force brute.

Fail2ban surveille les journaux des services protégés. Lorsqu'un nombre défini de tentatives échouées est détecté, l'adresse IP à l'origine des tentatives peut être temporairement bannie.

Dans le cadre de ce projet, la protection concerne principalement le service **SSH**, qui constitue l'un des services d'administration les plus exposés sur un serveur accessible à distance.

---

## 1. Installation de Fail2ban

On commence par mettre à jour l'index des paquets :

```bash
sudo apt update
```

Puis on installe Fail2ban :

```bash
sudo apt install fail2ban
```

Vérification de l'installation :

```bash
dpkg -l | grep fail2ban
```

---

## 2. Vérification du service

Après l'installation, on vérifie l'état du service :

```bash
sudo systemctl status fail2ban
```

Le service doit être dans l'état :

```text
Active: active (running)
```

Si nécessaire, on peut démarrer Fail2ban :

```bash
sudo systemctl start fail2ban
```

Et activer son démarrage automatique :

```bash
sudo systemctl enable fail2ban
```

Vérification :

```bash
systemctl is-enabled fail2ban
```

Résultat attendu :

```text
enabled
```

---

## 3. Configuration de Fail2ban

Les fichiers de configuration principaux de Fail2ban se trouvent dans :

```text
/etc/fail2ban/
```

On peut afficher leur contenu :

```bash
ls -l /etc/fail2ban/
```

On évite de modifier directement le fichier :

```text
/etc/fail2ban/jail.conf
```

car ce fichier peut être remplacé lors d'une mise à jour du paquet.

La configuration locale est placée dans :

```text
/etc/fail2ban/jail.local
```

Création du fichier :

```bash
sudo nano /etc/fail2ban/jail.local
```

---

## 4. Protection du service SSH

La configuration suivante active la protection SSH :

```ini
[sshd]

enabled = true
port = ssh
backend = systemd
maxretry = 3
findtime = 10m
bantime = 24h
```

### Explication

| Paramètre           | Signification                                                        |
| ------------------- | -------------------------------------------------------------------- |
| `enabled = true`    | Active la protection SSH                                             |
| `port = ssh`        | Utilise le port associé au service SSH                               |
| `backend = systemd` | Utilise les journaux du système via systemd                          |
| `maxretry = 3`      | Nombre maximal de tentatives échouées                                |
| `findtime = 10m`    | Fenêtre de temps pendant laquelle les tentatives sont comptabilisées |
| `bantime = 24h`      | Durée du bannissement                                                |

Ainsi, une adresse IP qui effectue plusieurs tentatives d'authentification SSH échouées dans un court intervalle peut être temporairement bannie.

---

## 5. Prise en compte du port SSH

La valeur du port doit correspondre à la configuration réalisée lors de la phase 3.

Si SSH utilise le port standard :

```ini
port = 22
```

Si le port SSH a été modifié, par exemple vers `2222` :

```ini
port = 2222
```

Il est donc important de vérifier la configuration SSH avant d'activer la protection :

```bash
sudo sshd -T | grep '^port'
```

---

## 6. Redémarrage de Fail2ban

Après modification de la configuration :

```bash
sudo systemctl restart fail2ban
```

Puis :

```bash
sudo systemctl status fail2ban
```

Il faut vérifier qu'aucune erreur de configuration n'est présente.

---

## 7. Vérification des jails actives

Fail2ban utilise le concept de **jail**.

Pour afficher les jails actuellement actives :

```bash
sudo fail2ban-client status
```

Exemple :

```text
Status
|- Number of jail: 1
`- Jail list: sshd
```

La présence de `sshd` confirme que la protection SSH est active.

---

## 8. Vérification détaillée de la jail SSH

Pour obtenir les informations détaillées :

```bash
sudo fail2ban-client status sshd
```

On peut notamment obtenir :

* le nombre d'échecs détectés ;
* le nombre d'adresses actuellement bannies ;
* la liste des adresses bannies ;
* le nombre total de bannissements.

Exemple :

```text
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 0
`- Actions
   |- Currently banned: 0
   |- Total banned: 0
```

Un nombre de bannissements égal à zéro n'est pas une erreur : cela signifie simplement qu'aucune adresse IP n'a encore dépassé le seuil configuré.

---

## 9. Consultation des logs

Fail2ban peut être suivi avec journalctl :

```bash
sudo journalctl -u fail2ban
```

Pour suivre les événements en temps réel :

```bash
sudo journalctl -u fail2ban -f
```

On peut également consulter le journal traditionnel de Fail2ban lorsqu'il est disponible :

```bash
sudo tail -f /var/log/fail2ban.log
```

---

## 10. Vérification de la protection SSH

Une fois Fail2ban configuré, on vérifie les différents éléments :

### Service

```bash
systemctl status fail2ban
```

### Jails

```bash
sudo fail2ban-client status
```

### Protection SSH

```bash
sudo fail2ban-client status sshd
```

### Port SSH

```bash
sudo ss -tlnp | grep ssh
```

Ces vérifications permettent de confirmer que la protection correspond bien au service SSH réellement utilisé.

---

## 11. Gestion manuelle d'une adresse IP

Fail2ban permet également de consulter et de gérer manuellement les bannissements.

Pour bannir une adresse IP :

```bash
sudo fail2ban-client set sshd banip <IP>
```

Pour supprimer le bannissement :

```bash
sudo fail2ban-client set sshd unbanip <IP>
```

Pour afficher les adresses bannies :

```bash
sudo fail2ban-client status sshd
```

> Ces commandes sont principalement utiles pour l'administration et les tests. Une adresse IP légitime ne doit pas être bannie accidentellement.

---

## 12. Relation avec UFW

Fail2ban constitue une couche complémentaire au pare-feu configuré lors de la phase 4.

**UFW** contrôle les connexions selon des règles réseau.

**Fail2ban** réagit aux comportements détectés dans les journaux des services.

On obtient donc une défense complémentaire :

```text
Connexion réseau
       │
       ▼
      UFW
       │
       ▼
   Service SSH
       │
       ▼
    Journaux
       │
       ▼
    Fail2ban
       │
       ▼
 Bannissement temporaire
```

Fail2ban ne remplace donc pas le pare-feu. Il vient renforcer la protection des services exposés.

---

## 13. Résultat attendu

À la fin de cette phase :

* Fail2ban est installé ;
* le service démarre automatiquement ;
* la jail SSH est activée ;
* les tentatives d'authentification échouées sont surveillées ;
* un seuil de tentatives est défini ;
* une durée de bannissement est définie ;
* l'état de la protection peut être contrôlé avec `fail2ban-client` ;
* les événements peuvent être consultés dans les journaux.

Le serveur dispose ainsi d'une protection supplémentaire contre les tentatives répétées d'authentification SSH.

---

## 14. Commandes principales

```bash
# Installation
sudo apt update
sudo apt install fail2ban

# Service
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo systemctl status fail2ban

# Configuration
sudo nano /etc/fail2ban/jail.local

# Redémarrage après modification
sudo systemctl restart fail2ban

# Jails actives
sudo fail2ban-client status

# État de SSH
sudo fail2ban-client status sshd

# Journaux
sudo journalctl -u fail2ban
sudo journalctl -u fail2ban -f
```

---

## Conclusion

Fail2ban permet de limiter l'impact des attaques automatisées visant les services d'administration.

Dans ce projet, il est utilisé comme une couche de protection complémentaire à **SSH durci** et au **pare-feu UFW**.

La phase suivante porte sur le **durcissement du noyau Linux et des paramètres réseau**.
