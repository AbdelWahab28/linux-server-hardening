# Scripts d'exécution globale

## Objectif

Le dossier `scripts-all/` regroupe les scripts permettant d'exécuter les différentes phases du projet **Linux Server Hardening** depuis un point central.

L'objectif est de faciliter le déploiement du projet sur un nouveau serveur Linux basé sur Debian.

Au lieu d'exécuter manuellement chaque script :

```text
phase-0/hardening.sh
phase-1/hardening.sh
phase-2/hardening.sh
...
phase-7/hardening.sh
```

le script global permet de lancer les phases dans l'ordre prévu par le projet.

## Utilisation

Depuis la racine du dépôt :

```bash
chmod +x scripts-all/hardening-all.sh
sudo ./scripts-all/hardening-all.sh
```

## Attention

Le script global ne doit pas être considéré comme un mécanisme permettant de durcir aveuglément n'importe quel serveur.

Certaines phases peuvent modifier des éléments critiques du système, notamment :

* les comptes utilisateurs ;
* SSH ;
* le pare-feu ;
* les paramètres réseau ;
* les règles Auditd.

Il est donc recommandé de lire le README de chaque phase avant une première exécution.

## Exécution individuelle

Chaque phase peut également être exécutée indépendamment :

```bash
sudo ./phase-0/hardening.sh
sudo ./phase-1/hardening.sh
sudo ./phase-2/hardening.sh
sudo ./phase-3/hardening.sh
sudo ./phase-4/hardening.sh
sudo ./phase-5/hardening.sh
sudo ./phase-6/hardening.sh
sudo ./phase-7/hardening.sh
```

Cette méthode est recommandée lorsqu'une configuration doit être adaptée au serveur cible.
