# Méthodologie de durcissement — Linux Server Hardening

## 1. Objectif

La méthodologie définit l'approche suivie pour sécuriser un serveur Linux avant son utilisation.

Le durcissement est réalisé progressivement afin de réduire les risques de mauvaise configuration, de perte d'accès et d'intervention non maîtrisée.

---

## 2. Principe général

Le projet suit le cycle :

```text
Identifier
    ↓
Préparer
    ↓
Durcir
    ↓
Contrôler
    ↓
Auditer
    ↓
Améliorer
```

Le durcissement ne doit pas être considéré comme une opération unique.

Il s'agit d'un processus permettant de réduire progressivement la surface d'attaque du système.

---

## 3. Phase 0 — Analyse et préparation

La première étape consiste à connaître l'état initial du serveur.

Les informations importantes sont notamment :

* version du système ;
* version du noyau ;
* nom de la machine ;
* interfaces réseau ;
* adresses IP ;
* routes ;
* utilisateurs et groupes ;
* services actifs ;
* ports ouverts.

Le système est ensuite mis à jour avant de commencer les opérations de durcissement.

Cette phase constitue la référence de départ du projet.

---

## 4. Phase 1 — Comptes et privilèges

La gestion des comptes constitue une étape fondamentale.

L'objectif est de :

* disposer d'un compte administrateur approprié ;
* éviter l'utilisation quotidienne du compte `root` ;
* contrôler les privilèges `sudo` ;
* appliquer le principe du moindre privilège.

---

## 5. Phase 2 — Préparation administrative

Cette phase prépare le serveur pour les opérations d'administration sécurisée.

Elle permet notamment de préparer l'environnement nécessaire avant la sécurisation de l'administration distante.

---

## 6. Phase 3 — Sécurisation SSH

SSH représente une surface d'exposition importante lorsqu'un serveur est administré à distance.

La phase comprend :

1. installation d'OpenSSH si nécessaire ;
2. génération d'une paire de clés sur le poste administrateur ;
3. déploiement de la clé publique sur le serveur ;
4. test de l'authentification par clé ;
5. sauvegarde de la configuration SSH ;
6. désactivation de la connexion root distante ;
7. désactivation de l'authentification par mot de passe ;
8. changement du port SSH ;
9. vérification de la configuration.

Une modification SSH ne doit jamais être appliquée avant d'avoir vérifié que l'accès par clé fonctionne.

---

## 7. Phase 4 — Filtrage réseau

UFW est utilisé afin de contrôler les connexions entrantes et sortantes selon la politique définie.

L'objectif est de réduire les services directement accessibles depuis le réseau.

Le principe appliqué est :

> Refuser par défaut et n'autoriser que les flux nécessaires.

---

## 8. Phase 5 — Protection contre le brute force

Fail2ban complète le pare-feu en analysant certains événements et en appliquant des mesures temporaires contre les adresses présentant un comportement suspect.

La protection concerne notamment les tentatives répétées d'authentification SSH.

---

## 9. Phase 6 — Kernel Hardening

Cette phase renforce certains paramètres du noyau Linux et de la pile réseau.

L'objectif est notamment de réduire l'exposition à certaines techniques d'exploitation et de renforcer le comportement réseau du système.

Les paramètres doivent être appliqués avec prudence car certains réglages peuvent avoir un impact sur les applications ou services.

---

## 10. Phase 7 — Audit

La dernière phase permet de contrôler le résultat du durcissement.

Plusieurs outils sont utilisés :

* **Lynis** pour l'audit de sécurité et le contrôle de configuration ;
* **Auditd** pour la journalisation des événements de sécurité ;
* **AIDE** pour le contrôle de l'intégrité des fichiers ;
* **RKHunter** pour la détection d'éléments potentiellement malveillants.

L'objectif n'est pas uniquement d'obtenir un score élevé.

Les résultats doivent être analysés afin d'identifier les points nécessitant encore une amélioration.

---

## 11. Validation

Après chaque modification importante, le système doit être contrôlé.

Les contrôles peuvent notamment porter sur :

* l'état des services ;
* la connectivité réseau ;
* l'accès SSH ;
* les règles du pare-feu ;
* les journaux ;
* les règles d'audit ;
* les résultats des outils de sécurité.

---

## 12. Principe de réversibilité

Avant toute modification critique, une sauvegarde de la configuration concernée doit être réalisée lorsque cela est possible.

Cela permet de revenir à l'état précédent en cas de problème.

Les éléments particulièrement sensibles sont notamment :

* configuration SSH ;
* règles du pare-feu ;
* paramètres réseau ;
* paramètres du noyau ;
* règles Auditd.

---

## 13. Adaptation à l'environnement

Le script fourni par le projet constitue une base d'automatisation.

Il ne doit pas remplacer l'analyse de l'environnement cible.

Avant de lancer une phase, l'administrateur doit vérifier :

* le rôle du serveur ;
* les services nécessaires ;
* les ports utilisés ;
* les accès administratifs ;
* les contraintes applicatives ;
* les exigences réseau.

Une configuration de durcissement adaptée à un serveur SSH ne sera pas nécessairement adaptée à un serveur Web, une base de données ou un serveur Kubernetes.

---

## 14. Résultat attendu

À la fin du processus, le serveur doit présenter :

* une surface d'attaque réduite ;
* des comptes et privilèges maîtrisés ;
* une administration distante sécurisée ;
* un filtrage réseau actif ;
* une protection contre les tentatives répétées d'authentification ;
* des paramètres système renforcés ;
* une capacité d'audit et de contrôle de l'intégrité.
