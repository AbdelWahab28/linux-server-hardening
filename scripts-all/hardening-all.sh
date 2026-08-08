#!/bin/bash

# ============================================================
# Linux Server Hardening
# Exécution globale des phases
# ============================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "============================================================"
echo "       LINUX SERVER HARDENING"
echo "       Exécution globale du projet"
echo "============================================================"
echo

# ------------------------------------------------------------
# Vérification des privilèges
# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être exécuté avec sudo."
    echo
    echo "Utilisation :"
    echo "  sudo ./scripts-all/hardening-all.sh"
    exit 1
fi

# ------------------------------------------------------------
# Présentation
# ------------------------------------------------------------

echo "Ce script va exécuter les phases du projet dans l'ordre :"
echo
echo "  Phase 0 - Préparation du système"
echo "  Phase 1 - Gestion des comptes et privilèges"
echo "  Phase 2 - Préparation administrative"
echo "  Phase 3 - Sécurisation SSH"
echo "  Phase 4 - Pare-feu UFW"
echo "  Phase 5 - Protection Fail2ban"
echo "  Phase 6 - Kernel Hardening"
echo "  Phase 7 - Audit de sécurité"
echo

echo "[ATTENTION]"
echo "Certaines phases modifient la configuration du serveur."
echo "Vérifiez les README de chaque phase avant de continuer."
echo

read -r -p "Voulez-vous continuer ? [y/N] " response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Exécution annulée."
    exit 0
fi

echo

# ------------------------------------------------------------
# Liste des phases
# ------------------------------------------------------------

PHASES=(
    "phase-0"
    "phase-1"
    "phase-2"
    "phase-3"
    "phase-4"
    "phase-5"
    "phase-6"
    "phase-7"
)

# ------------------------------------------------------------
# Vérification des scripts
# ------------------------------------------------------------

echo "[INFO] Vérification des scripts..."

for phase in "${PHASES[@]}"; do

    SCRIPT="$PROJECT_ROOT/$phase/hardening.sh"

    if [ ! -f "$SCRIPT" ]; then
        echo "[ERREUR] Script introuvable : $SCRIPT"
        exit 1
    fi

    if [ ! -x "$SCRIPT" ]; then
        chmod +x "$SCRIPT"
    fi

done

echo "[OK] Tous les scripts sont disponibles."
echo

# ------------------------------------------------------------
# Exécution des phases
# ------------------------------------------------------------

for phase in "${PHASES[@]}"; do

    SCRIPT="$PROJECT_ROOT/$phase/hardening.sh"

    echo
    echo "============================================================"
    echo " $phase"
    echo "============================================================"
    echo

    "$SCRIPT"

    echo
    echo "[OK] $phase terminée."
    echo

done

# ------------------------------------------------------------
# Fin
# ------------------------------------------------------------

echo
echo "============================================================"
echo "      DURCISSEMENT TERMINÉ"
echo "============================================================"
echo
echo "Toutes les phases ont été exécutées avec succès."
echo
echo "Pensez à consulter les résultats des audits de la phase 7."
echo