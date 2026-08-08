# Phase 6 — Durcissement du noyau Linux et des paramètres réseau

## Objectif

Cette phase consiste à renforcer la sécurité du noyau Linux et de certains paramètres réseau à l'aide de **sysctl**.

Le noyau Linux expose de nombreux paramètres permettant de contrôler le comportement du système. Certains peuvent être configurés afin de réduire les risques liés à :

* l'usurpation d'adresse IP ;
* le routage de paquets inattendu ;
* les redirections ICMP ;
* les réponses aux broadcasts ;
* certaines formes d'attaque réseau ;
* l'exposition d'informations liées au noyau.

L'objectif n'est pas de modifier tous les paramètres disponibles, mais uniquement ceux qui apportent un bénéfice de sécurité tout en conservant un comportement compatible avec un serveur Linux classique.

---

# 1. Vérification de la configuration actuelle

Avant toute modification, il est important de connaître les valeurs actuellement utilisées.

On peut afficher les paramètres réseau principaux avec :

```bash
sysctl net.ipv4.ip_forward
sysctl net.ipv4.conf.all.accept_redirects
sysctl net.ipv4.conf.default.accept_redirects
sysctl net.ipv4.conf.all.send_redirects
sysctl net.ipv4.conf.default.send_redirects
sysctl net.ipv4.conf.all.accept_source_route
sysctl net.ipv4.conf.default.accept_source_route
sysctl net.ipv4.conf.all.rp_filter
sysctl net.ipv4.conf.default.rp_filter
```

On peut également afficher l'ensemble des paramètres IPv4 :

```bash
sysctl -a | grep '^net.ipv4'
```

Cette étape permet de conserver une vision claire de la configuration avant son durcissement.

---

# 2. Création du fichier de configuration

Les paramètres persistants de `sysctl` peuvent être placés dans :

```text
/etc/sysctl.d/
```

Pour ce projet, un fichier dédié est créé :

```bash
sudo nano /etc/sysctl.d/99-hardening.conf
```

Cette méthode est préférable à la modification directe de :

```text
/etc/sysctl.conf
```

car elle permet de conserver une configuration de durcissement indépendante du reste de la configuration système.

---

# 3. Désactivation du routage IPv4

Sur un serveur classique qui n'a pas pour fonction d'être un routeur, le routage IPv4 peut être désactivé :

```ini
net.ipv4.ip_forward = 0
```

Cela empêche le système de transférer des paquets IPv4 entre différentes interfaces réseau.

> Si le serveur fonctionne comme routeur, firewall, passerelle ou équipement réseau, ce paramètre ne doit pas être désactivé sans analyse préalable.

---

# 4. Désactivation des redirections ICMP

Les redirections ICMP peuvent être utilisées pour modifier les informations de routage d'un système.

On désactive leur acceptation :

```ini
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
```

On désactive également l'envoi de redirections :

```ini
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
```

Le système ne doit normalement pas utiliser les redirections ICMP pour un serveur standard.

---

# 5. Désactivation de l'acceptation des routes source

Le routage source permet à l'expéditeur d'un paquet de fournir une partie du chemin que celui-ci doit suivre.

Pour un serveur standard, cette fonctionnalité n'est généralement pas nécessaire.

On la désactive :

```ini
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
```

---

# 6. Activation du Reverse Path Filtering

Le **Reverse Path Filtering** permet au noyau de vérifier qu'une adresse source est cohérente avec l'interface par laquelle le paquet est reçu.

On active le mode strict :

```ini
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
```

Cette protection peut contribuer à limiter certains scénarios d'usurpation d'adresse IP.

> Dans des environnements réseau complexes utilisant du routage asymétrique, du multihoming ou certaines configurations VPN, le mode strict peut être problématique. Il faut donc adapter ce paramètre au rôle réel du serveur.

---

# 7. Désactivation des réponses aux broadcasts ICMP

Les réponses ICMP aux broadcasts peuvent être utilisées dans certaines attaques de type amplification.

On désactive ce comportement :

```ini
net.ipv4.icmp_echo_ignore_broadcasts = 1
```

Le serveur ignore ainsi les requêtes ICMP Echo envoyées à une adresse broadcast.

---

# 8. Protection contre les mauvais messages ICMP

On active également l'ignorance des erreurs ICMP non valides :

```ini
net.ipv4.icmp_ignore_bogus_error_responses = 1
```

Cela permet au noyau d'ignorer certains messages ICMP considérés comme incorrects.

---

# 9. Protection contre les SYN Cookies

Les SYN Cookies permettent au noyau de mieux résister à certaines attaques de saturation TCP basées sur les connexions SYN.

On vérifie la valeur actuelle :

```bash
sysctl net.ipv4.tcp_syncookies
```

Puis on active la protection :

```ini
net.ipv4.tcp_syncookies = 1
```

---

# 10. Application des paramètres

Une fois le fichier créé, les paramètres peuvent être appliqués avec :

```bash
sudo sysctl --system
```

Cette commande recharge les fichiers de configuration `sysctl` présents dans les répertoires prévus par le système.

On peut également appliquer spécifiquement notre fichier :

```bash
sudo sysctl -p /etc/sysctl.d/99-hardening.conf
```

---

# 11. Vérification des paramètres

Après application, les paramètres doivent être vérifiés.

```bash
sysctl net.ipv4.ip_forward
sysctl net.ipv4.conf.all.accept_redirects
sysctl net.ipv4.conf.default.accept_redirects
sysctl net.ipv4.conf.all.send_redirects
sysctl net.ipv4.conf.default.send_redirects
sysctl net.ipv4.conf.all.accept_source_route
sysctl net.ipv4.conf.default.accept_source_route
sysctl net.ipv4.conf.all.rp_filter
sysctl net.ipv4.conf.default.rp_filter
sysctl net.ipv4.icmp_echo_ignore_broadcasts
sysctl net.ipv4.icmp_ignore_bogus_error_responses
sysctl net.ipv4.tcp_syncookies
```

Les valeurs attendues sont :

| Paramètre                           | Valeur |
| ----------------------------------- | -----: |
| `net.ipv4.ip_forward`               |    `0` |
| `accept_redirects`                  |    `0` |
| `send_redirects`                    |    `0` |
| `accept_source_route`               |    `0` |
| `rp_filter`                         |    `1` |
| `icmp_echo_ignore_broadcasts`       |    `1` |
| `icmp_ignore_bogus_error_responses` |    `1` |
| `tcp_syncookies`                    |    `1` |

---

# 12. Vérification de la persistance

Les paramètres doivent rester actifs après un redémarrage du serveur.

On vérifie la présence du fichier :

```bash
ls -l /etc/sysctl.d/99-hardening.conf
```

On peut également afficher son contenu :

```bash
cat /etc/sysctl.d/99-hardening.conf
```

Après un redémarrage :

```bash
sudo reboot
```

Puis vérifier à nouveau :

```bash
sysctl net.ipv4.ip_forward
sysctl net.ipv4.tcp_syncookies
```

Cela permet de confirmer que la configuration est bien persistante.

---

# 13. Vérification du réseau après durcissement

Après modification des paramètres réseau, il est important de vérifier que le fonctionnement du serveur n'a pas été perturbé.

Vérification des interfaces :

```bash
ip a
```

Vérification de la table de routage :

```bash
ip route
```

Vérification de la connectivité :

```bash
ping -c 4 8.8.8.8
```

Vérification de la résolution DNS :

```bash
ping -c 4 google.com
```

Si le serveur est administré à distance, il faut également vérifier que SSH reste accessible.

---

# 14. Principe de sécurité appliqué

Cette phase applique le principe suivant :

> **Réduire les fonctionnalités réseau inutiles et renforcer les mécanismes de protection intégrés au noyau.**

Le durcissement du noyau vient compléter les protections déjà mises en place :

```text
                 Serveur Linux
                       │
        ┌──────────────┼──────────────┐
        │              │              │
       SSH            UFW          Fail2ban
        │              │              │
        └──────────────┼──────────────┘
                       │
                 Kernel Hardening
                       │
                    sysctl
                       │
              Paramètres réseau
```

---

# 15. Résultat attendu

À la fin de cette phase :

* les paramètres réseau inutiles sont désactivés ;
* le routage IPv4 est désactivé sur un serveur qui n'est pas routeur ;
* les redirections ICMP sont désactivées ;
* le source routing est désactivé ;
* le Reverse Path Filtering est activé ;
* les réponses ICMP broadcast sont ignorées ;
* les SYN Cookies sont activés ;
* la configuration est persistante ;
* les paramètres sont vérifiés après application ;
* la connectivité du serveur est contrôlée.

Le noyau et la pile réseau disposent ainsi d'une configuration plus restrictive adaptée à un serveur Linux classique.

---

## Commandes principales

```bash
# Voir la configuration actuelle
sysctl -a | grep '^net.ipv4'

# Créer la configuration
sudo nano /etc/sysctl.d/99-hardening.conf

# Appliquer les paramètres
sudo sysctl --system

# Vérifier les paramètres
sysctl net.ipv4.ip_forward
sysctl net.ipv4.tcp_syncookies

# Vérifier le réseau
ip a
ip route
```

---

## Conclusion

Le durcissement du noyau constitue une couche complémentaire aux mesures de sécurité mises en place précédemment.

Après la sécurisation des comptes, de SSH, du pare-feu et de Fail2ban, cette phase permet de renforcer directement le comportement du système et de sa pile réseau.

La phase suivante est consacrée à **l'audit de sécurité et au contrôle de conformité avec Lynis, Auditd, AIDE et RKHunter**.
