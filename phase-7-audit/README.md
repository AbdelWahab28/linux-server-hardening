# Phase 7 — Audit de sécurité et contrôle de conformité

## Objectif

Cette phase constitue l'étape de contrôle du projet **Linux Server Hardening**.

Après avoir appliqué les différentes mesures de durcissement, il est nécessaire de vérifier leur efficacité et de rechercher d'éventuelles anomalies.

L'objectif est donc de :

* réaliser un audit global de la configuration avec **Lynis** ;
* mettre en place et vérifier **Auditd** pour la journalisation des événements de sécurité ;
* utiliser **AIDE** pour détecter les modifications de fichiers sensibles ;
* utiliser **RKHunter** pour rechercher certains signes associés aux rootkits ;
* analyser les résultats et identifier les éventuels points restant à améliorer.

> **Important :** ces outils sont complémentaires. Aucun d'entre eux ne garantit à lui seul qu'un serveur est totalement sécurisé.

---

## 1. Outils utilisés

| Outil        | Rôle                                                 |
| ------------ | ---------------------------------------------------- |
| **Lynis**    | Audit de sécurité et recommandations de durcissement |
| **Auditd**   | Journalisation des événements liés à la sécurité     |
| **AIDE**     | Contrôle d'intégrité des fichiers                    |
| **RKHunter** | Recherche d'éléments suspects associés aux rootkits  |

---

# 2. Installation des outils

Sur les systèmes Debian, les outils peuvent être installés avec le gestionnaire de paquets :

```bash
sudo apt update
sudo apt install lynis auditd audispd-plugins aide rkhunter -y
```

Vérification :

```bash
lynis --version
auditctl -v
aide --version
rkhunter --version
```

---

# 3. Audit de sécurité avec Lynis

Lynis permet d'effectuer un audit global du serveur et d'identifier les mesures de sécurité déjà présentes ainsi que celles pouvant encore être améliorées.

Lancement de l'audit :

```bash
sudo lynis audit system
```

Le résultat fournit notamment :

* un **Hardening Index** ;
* les tests effectués ;
* les avertissements éventuels ;
* les recommandations de sécurité ;
* l'état de différents composants du système.

Les fichiers générés par Lynis peuvent également être consultés :

```bash
sudo less /var/log/lynis.log
```

et :

```bash
sudo less /var/log/lynis-report.dat
```

### Interprétation

Le **Hardening Index** permet de suivre l'évolution du niveau de durcissement au cours du projet.

Il ne doit cependant pas être considéré comme un score absolu de sécurité.

Dans le cadre du projet, Lynis est utilisé principalement pour :

1. identifier les faiblesses ;
2. appliquer les corrections pertinentes ;
3. relancer l'audit ;
4. comparer les résultats.

---

# 4. Mise en place d'Auditd

## Objectif

`auditd` permet de journaliser certains événements importants du système.

Il peut notamment surveiller les modifications apportées à des fichiers sensibles.

Vérification du service :

```bash
sudo systemctl status auditd
```

Activation au démarrage :

```bash
sudo systemctl enable auditd
```

Démarrage :

```bash
sudo systemctl start auditd
```

---

# 5. Création des règles Auditd

Les règles personnalisées sont placées dans :

```text
/etc/audit/rules.d/
```

Création du fichier :

```bash
sudo nano /etc/audit/rules.d/hardening.rules
```

Exemple de règles utilisées dans le projet :

```text
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity

-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d -p wa -k sudoers

-w /etc/ssh/sshd_config -p wa -k ssh_config

-w /etc/hosts -p wa -k network
-w /etc/network -p wa -k network

-w /usr/bin/sudo -p x -k sudo_usage
-w /bin/su -p x -k su_usage
```

Ces règles permettent notamment de surveiller :

* les fichiers liés aux comptes ;
* les fichiers liés à `sudo` ;
* la configuration SSH ;
* certains fichiers de configuration réseau ;
* l'utilisation de `sudo` et `su`.

---

# 6. Chargement des règles Auditd

Après modification du fichier :

```bash
sudo augenrules --load
```

Vérification :

```bash
sudo auditctl -l
```

Les règles doivent apparaître dans la sortie.

---

# 7. Vérification de la journalisation

Une règle peut être testée en modifiant volontairement un fichier surveillé.

Par exemple :

```bash
sudo nano /etc/hosts
```

Puis recherche des événements associés à la clé :

```bash
sudo ausearch -k network
```

Auditd doit alors afficher les événements correspondant à la modification.

Cela permet de vérifier que la surveillance fonctionne réellement.

---

# 8. Mise en place d'AIDE

## Objectif

AIDE (**Advanced Intrusion Detection Environment**) permet de créer une base de référence contenant l'état de fichiers et répertoires du système.

Lors d'un contrôle ultérieur, AIDE compare l'état actuel du système avec cette référence.

Installation :

```bash
sudo apt install aide -y
```

Initialisation de la base :

```bash
sudo aideinit
```

La commande génère une nouvelle base dans :

```text
/var/lib/aide/aide.db.new
```

Dans notre environnement, la base a ensuite été activée avec :

```bash
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

---

# 9. Contrôle d'intégrité avec AIDE

Le contrôle est effectué avec :

```bash
sudo aide --config /etc/aide/aide.conf --check
```

AIDE compare alors la base de référence avec l'état actuel du système.

Un résultat peut indiquer :

```text
Added entries
Removed entries
Changed entries
```

### Interprétation

Une modification n'est pas nécessairement une attaque.

Par exemple, pendant le projet, AIDE a détecté des changements sur :

```text
/etc/issue.net
/etc/ssh/sshd_config
/home/abdelwahab/.bash_history
/var/lib/fail2ban/fail2ban.sqlite3
/var/log/audit/audit.log
```

Ces modifications étaient cohérentes avec les opérations réalisées pendant le durcissement du serveur.

Il est donc important d'analyser les changements avant de considérer une alerte comme suspecte.

Après une modification volontaire et validée de la configuration, la base AIDE peut être reconstruite afin de prendre ce nouvel état comme référence.

---

# 10. Vérification avec RKHunter

RKHunter (**Rootkit Hunter**) permet de rechercher certains indicateurs pouvant être associés à des rootkits ou à des modifications suspectes du système.

Mise à jour :

```bash
sudo rkhunter --update
```

Vérification des fichiers de configuration :

```bash
sudo rkhunter --propupd
```

Analyse du système :

```bash
sudo rkhunter --check
```

Les résultats sont disponibles dans :

```text
/var/log/rkhunter.log
```

Pour consulter le journal :

```bash
sudo less /var/log/rkhunter.log
```

---

# 11. Analyse des résultats

La phase d'audit ne consiste pas uniquement à lancer les commandes.

Les résultats doivent être analysés afin de distinguer :

* les changements légitimes ;
* les avertissements nécessitant une vérification ;
* les recommandations de durcissement ;
* les événements réellement suspects.

Les outils ont des objectifs différents :

```text
Lynis
  ↓
Audit global du système

Auditd
  ↓
Journalisation des événements

AIDE
  ↓
Contrôle d'intégrité

RKHunter
  ↓
Recherche d'éléments suspects
```

---

# 12. Commandes principales de la phase

```bash
# Lynis
sudo lynis audit system

# Auditd
sudo systemctl status auditd
sudo auditctl -l
sudo ausearch -k network

# AIDE
sudo aideinit
sudo aide --config /etc/aide/aide.conf --check

# RKHunter
sudo rkhunter --update
sudo rkhunter --check
```

---

# 13. Résultat attendu

À la fin de cette phase, le serveur doit disposer :

* d'un audit de sécurité réalisé avec Lynis ;
* d'un service Auditd actif ;
* de règles Auditd permettant de surveiller plusieurs fichiers sensibles ;
* d'une base AIDE initialisée ;
* d'un contrôle d'intégrité fonctionnel ;
* d'une analyse RKHunter réalisée ;
* de journaux permettant de conserver les traces des contrôles.

---

# 14. Limites

Cette phase constitue une **première couche de supervision et de contrôle**, mais elle ne remplace pas une véritable infrastructure de monitoring et de détection.

Dans ce projet, la supervision continue du serveur n'est volontairement pas développée afin de conserver un périmètre centré sur le **durcissement du système**.

Une future évolution pourra intégrer :

* une centralisation des journaux ;
* un SIEM ;
* une supervision système ;
* une détection d'incidents ;
* des alertes automatisées ;
* une analyse continue de conformité.

---

## Conclusion

Cette phase permet de vérifier le résultat du durcissement réalisé dans les phases précédentes.

Le serveur ne se contente donc plus d'être configuré de manière sécurisée : son état peut également être **audité, journalisé et contrôlé**.

Elle constitue ainsi la dernière étape du cycle de durcissement :

```text
Préparer
   ↓
Configurer
   ↓
Durcir
   ↓
Protéger
   ↓
Auditer
   ↓
Contrôler
```