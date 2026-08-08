# Architecture du projet — Linux Server Hardening

## 1. Présentation

Le projet **Linux Server Hardening** a pour objectif de fournir une méthode structurée et reproductible permettant de renforcer la sécurité d'un serveur Linux avant son utilisation en environnement de production.

Le projet est organisé sous forme de plusieurs phases indépendantes. Chaque phase possède :

* un fichier `README.md` décrivant les objectifs et les opérations réalisées ;
* un script `hardening.sh` permettant d'automatiser les opérations ;
* des contrôles permettant de vérifier le résultat lorsque cela est nécessaire.

Cette organisation permet d'utiliser le projet aussi bien comme documentation technique que comme base d'automatisation.

---

## 2. Architecture générale

```text
                         Linux Server
                              │
                              ▼
                    ┌─────────────────────┐
                    │       Phase 0       │
                    │ Analyse & préparation│
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │       Phase 1       │
                    │ Comptes & privilèges│
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │       Phase 2       │
                    │ Préparation admin.  │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │       Phase 3       │
                    │   Sécurisation SSH  │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │       Phase 4       │
                    │      Pare-feu UFW   │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │       Phase 5       │
                    │      Fail2ban       │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │       Phase 6       │
                    │   Kernel Hardening  │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │       Phase 7       │
                    │ Audit & conformité  │
                    └─────────────────────┘
```

---

## 3. Organisation du dépôt

Le dépôt est divisé en trois grandes parties.

### 3.1 Documentation

Le dossier `docs/` contient la documentation transverse du projet.

```text
docs/
├── architecture.md
├── methodology.md
└── security-policy.md
```

Ces documents ne sont pas liés à une seule phase mais décrivent le fonctionnement global du projet.

### 3.2 Phases de durcissement

Chaque phase est isolée dans son propre dossier.

```text
phase-X/
├── README.md
└── hardening.sh
```

Cette séparation permet d'exécuter une phase individuellement sans devoir exécuter l'ensemble du processus.

### 3.3 Orchestration

Le dossier `scripts/` contient les scripts permettant d'orchestrer plusieurs phases.

```text
scripts/
└── hardening-all.sh
```

`hardening-all.sh` ne contient pas la logique de durcissement.

Il appelle les scripts des différentes phases dans l'ordre défini par le projet.

---

## 4. Principe d'indépendance des phases

Chaque phase doit rester suffisamment indépendante pour pouvoir être :

* exécutée séparément ;
* vérifiée séparément ;
* adaptée à un environnement particulier ;
* modifiée sans modifier les autres phases.

Cette approche limite également les risques liés à l'automatisation complète du processus.

---

## 5. Principe d'orchestration

L'orchestrateur suit le modèle :

```text
hardening-all.sh
       │
       ├── phase-0/hardening.sh
       ├── phase-1/hardening.sh
       ├── phase-2/hardening.sh
       ├── phase-3/hardening.sh
       ├── phase-4/hardening.sh
       ├── phase-5/hardening.sh
       ├── phase-6/hardening.sh
       └── phase-7/hardening.sh
```

L'orchestrateur est donc responsable uniquement de l'enchaînement des opérations.

La logique de sécurité reste dans les phases correspondantes.

---

## 6. Portée

Le projet est destiné aux systèmes Linux basés sur Debian et utilisant les outils standards disponibles dans cet écosystème.

Les scripts doivent toutefois vérifier les prérequis nécessaires avant d'effectuer des modifications importantes.

Une adaptation peut être nécessaire selon :

* la distribution ;
* le système d'initialisation ;
* le gestionnaire de paquets ;
* le service SSH ;
* la configuration réseau ;
* les logiciels installés ;
* le rôle du serveur.

---

## 7. Principe de sécurité

Le projet suit une approche **Defense in Depth**.

La sécurité ne repose pas sur une seule mesure.

Elle combine notamment :

* gestion des comptes ;
* contrôle des privilèges ;
* sécurisation SSH ;
* filtrage réseau ;
* protection contre le brute force ;
* durcissement du noyau ;
* audit et contrôle de l'intégrité ;
* vérification de la configuration.

Une compromission d'une couche ne doit donc pas automatiquement entraîner la compromission complète du serveur.
