#!/bin/bash

# ============================================================

# Linux Server Hardening

# Orchestrateur principal

# ============================================================

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ------------------------------------------------------------

# Couleurs

# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ------------------------------------------------------------

# Vérification des privilèges

# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
echo -e "${RED}[ERREUR]${NC} Ce script doit être exécuté avec sudo."
echo "Exemple : sudo ./scripts/hardening-all.sh"
exit 1
fi

# ------------------------------------------------------------

# Fonction d'exécution d'une phase

# ------------------------------------------------------------

run_phase() {

```
local PHASE="$1"
local DESCRIPTION="$2"

echo
echo "============================================================"
echo -e "${BLUE}Phase ${PHASE}${NC} — ${DESCRIPTION}"
echo "============================================================"

SCRIPT="${PROJECT_DIR}/phase-${PHASE}/hardening.sh"

if [ ! -f "$SCRIPT" ]; then
    echo -e "${RED}[ERREUR]${NC} Script introuvable : $SCRIPT"
    exit 1
fi

if [ ! -x "$SCRIPT" ]; then
    echo -e "${YELLOW}[INFO]${NC} Ajout du droit d'exécution..."
    chmod +x "$SCRIPT"
fi

echo -e "${GREEN}[INFO]${NC} Lancement de la phase ${PHASE}..."

"$SCRIPT"

echo
echo -e "${GREEN}[OK]${NC} Phase ${PHASE} terminée."
echo
```

}

# ------------------------------------------------------------

# Confirmation avant lancement

# ------------------------------------------------------------

echo
echo "============================================================"
echo "        LINUX SERVER HARDENING"
echo "============================================================"
echo
echo "Cet orchestrateur va exécuter les phases de durcissement"
echo "dans l'ordre."
echo
echo "Attention : certaines phases modifient la configuration"
echo "du système, du réseau et des services."
echo
echo "Il est recommandé d'exécuter et de valider chaque phase"
echo "individuellement avant d'utiliser cet orchestrateur."
echo

read -r -p "Voulez-vous continuer ? [y/N] : " RESPONSE

case "$RESPONSE" in
y|Y|yes|YES|o|O|oui|Oui)
;;
*)
echo
echo "Exécution annulée."
exit 0
;;
esac

# ------------------------------------------------------------

# Exécution des phases

# ------------------------------------------------------------

run_phase 0 "Analyse initiale et préparation du système"

run_phase 1 "Gestion et sécurisation des comptes utilisateurs"

run_phase 2 "Préparation et configuration administrative"

run_phase 3 "Sécurisation de l'administration distante avec SSH"

run_phase 4 "Mise en place du pare-feu avec UFW"

run_phase 5 "Protection contre les attaques brute force avec Fail2ban"

run_phase 6 "Durcissement du noyau Linux et des paramètres réseau"

run_phase 7 "Audit de sécurité et contrôle de conformité"

# ------------------------------------------------------------

# Fin

# ------------------------------------------------------------

echo
echo "============================================================"
echo -e "${GREEN}        DURCISSEMENT TERMINÉ${NC}"
echo "============================================================"
echo
echo "Toutes les phases ont été exécutées avec succès."
echo
echo "Il est recommandé de :"
echo "  - vérifier l'état des services"
echo "  - vérifier la connectivité SSH"
echo "  - vérifier les règles UFW"
echo "  - consulter les résultats des audits"
echo "  - redémarrer le serveur si nécessaire"
echo
echo "============================================================"
