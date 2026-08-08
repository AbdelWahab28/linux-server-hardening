# Politique de sécurité — Linux Server Hardening

## 1. Objet

Cette politique définit les principes de sécurité appliqués aux serveurs Linux durcis avec le projet **Linux Server Hardening**.

Elle constitue un cadre de référence permettant de maintenir une configuration cohérente et sécurisée.

---

## 2. Gestion des comptes

Chaque administrateur doit utiliser son propre compte.

Le partage d'un compte administrateur entre plusieurs personnes est déconseillé.

L'accès aux privilèges élevés doit être réalisé avec `sudo` lorsque cela est possible.

Le compte `root` ne doit pas être utilisé pour les opérations quotidiennes.

---

## 3. Principe du moindre privilège

Les utilisateurs et services doivent disposer uniquement des privilèges nécessaires à leur fonctionnement.

Les permissions excessives doivent être évitées.

Les privilèges administratifs doivent être accordés uniquement aux utilisateurs qui en ont besoin.

---

## 4. Administration distante

L'administration distante doit utiliser SSH.

Lorsque cela est possible :

* l'authentification par clé SSH doit être privilégiée ;
* la connexion root distante doit être désactivée ;
* l'authentification SSH par mot de passe doit être désactivée après validation de l'authentification par clé ;
* la configuration SSH doit être vérifiée après modification.

---

## 5. Exposition réseau

Un serveur ne doit exposer que les ports nécessaires à son fonctionnement.

Le pare-feu doit appliquer une politique restrictive.

Tout nouveau service réseau doit être évalué avant d'être exposé.

---

## 6. Protection contre les attaques par force brute

Les services exposés aux tentatives d'authentification répétées doivent bénéficier de mesures de protection appropriées.

Fail2ban peut être utilisé pour détecter et limiter certains comportements de brute force.

Les règles doivent être adaptées au service concerné afin d'éviter les blocages légitimes.

---

## 7. Mise à jour du système

Le système d'exploitation et les logiciels installés doivent être maintenus à jour.

Les mises à jour de sécurité doivent être appliquées dans un délai raisonnable en fonction de leur criticité et des contraintes du serveur.

---

## 8. Configuration système

Les paramètres de sécurité du noyau et du réseau doivent être configurés selon les besoins du serveur.

Toute modification susceptible d'affecter les applications doit être testée avant son déploiement en production.

---

## 9. Journalisation et audit

Les événements de sécurité importants doivent être journalisés.

Auditd peut être utilisé pour surveiller les modifications concernant notamment :

* les comptes ;
* les groupes ;
* les fichiers sensibles ;
* les privilèges ;
* la configuration SSH ;
* certains paramètres réseau.

Les journaux doivent être protégés contre les modifications non autorisées.

---

## 10. Intégrité des fichiers

AIDE peut être utilisé pour établir une référence de l'état du système et détecter les modifications ultérieures de fichiers surveillés.

Toute modification légitime d'un fichier surveillé doit être identifiée et prise en compte avant la mise à jour de la référence d'intégrité.

---

## 11. Contrôle de sécurité

Des audits périodiques doivent être réalisés afin d'identifier les nouvelles faiblesses ou les écarts de configuration.

Les résultats de Lynis, Auditd, AIDE et RKHunter doivent être analysés et documentés lorsque cela est nécessaire.

---

## 12. Gestion des changements

Toute modification importante de la configuration de sécurité doit être documentée.

Avant une modification critique :

1. identifier le changement ;
2. sauvegarder la configuration concernée ;
3. appliquer le changement ;
4. vérifier le fonctionnement ;
5. documenter le résultat.

---

## 13. Secrets et informations sensibles

Les informations sensibles ne doivent jamais être stockées dans le dépôt Git.

Cela comprend notamment :

* clés privées SSH ;
* mots de passe ;
* tokens ;
* certificats privés ;
* fichiers `.env` contenant des secrets ;
* données spécifiques à un serveur de production.

Les fichiers sensibles doivent être exclus du dépôt à l'aide du `.gitignore`.

---

## 14. Responsabilité de l'administrateur

L'automatisation ne remplace pas la validation humaine.

L'administrateur reste responsable de vérifier que les règles appliquées correspondent au rôle et aux contraintes du serveur cible.

Une phase peut être adaptée, reportée ou exécutée manuellement lorsqu'elle n'est pas compatible avec l'environnement.

---

## 15. Révision de la politique

Cette politique doit être réévaluée lorsque :

* l'architecture du serveur évolue ;
* de nouveaux services sont déployés ;
* les exigences de sécurité changent ;
* de nouvelles menaces apparaissent ;
* les outils de sécurité sont remplacés ou mis à jour.

La sécurité du serveur doit être considérée comme un processus continu plutôt qu'une configuration définitive.
