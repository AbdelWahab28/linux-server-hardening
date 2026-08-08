
---

### `phase-01-comptes-et-privileges/hardening.sh`

```bash
#!/bin/bash

# ============================================================
# Linux Server Hardening
# Phase 1 — Gestion des comptes et des privilèges
#
# Compatible avec les distributions Linux basées sur Debian
# ============================================================

set -u

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

# ------------------------------------------------------------
# Vérification des privilèges
# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    error "Ce script doit être exécuté avec sudo ou en tant que root."
    exit 1
fi

# ------------------------------------------------------------
# Vérification de la distribution
# ------------------------------------------------------------

if [ ! -f /etc/os-release ]; then
    error "Impossible d'identifier la distribution."
    exit 1
fi

source /etc/os-release

if [ "$ID" != "debian" ] && [[ "${ID_LIKE:-}" != *"debian"* ]]; then
    error "Cette phase nécessite une distribution basée sur Debian."
    exit 1
fi

# ------------------------------------------------------------
# Vérification de sudo
# ------------------------------------------------------------

if ! command -v sudo >/dev/null 2>&1; then
    error "Le paquet sudo n'est pas installé."
    error "Installez sudo avant d'exécuter cette phase."
    exit 1
fi

echo
echo "============================================================"
echo "     LINUX SERVER HARDENING — PHASE 1"
echo "     Gestion des comptes et des privilèges"
echo "============================================================"
echo

# ------------------------------------------------------------
# Vérification des utilisateurs existants
# ------------------------------------------------------------

info "Utilisateurs locaux présents sur le système :"

awk -F: '$3 >= 1000 && $3 < 65534 {
    printf "  - %-20s UID=%s\n", $1, $3
}' /etc/passwd

echo

# ------------------------------------------------------------
# Vérification du groupe sudo
# ------------------------------------------------------------

info "Vérification du groupe sudo..."

if getent group sudo >/dev/null 2>&1; then
    success "Le groupe sudo existe."
else
    warning "Le groupe sudo n'existe pas."
    info "Création du groupe sudo..."

    groupadd sudo

    success "Groupe sudo créé."
fi

echo

# ------------------------------------------------------------
# Demande du nom du compte
# ------------------------------------------------------------

read -rp "Nom du compte administrateur à utiliser : " ADMIN_USER

if [ -z "$ADMIN_USER" ]; then
    error "Le nom du compte ne peut pas être vide."
    exit 1
fi

# ------------------------------------------------------------
# Vérification de l'existence du compte
# ------------------------------------------------------------

if id "$ADMIN_USER" >/dev/null 2>&1; then

    warning "L'utilisateur '$ADMIN_USER' existe déjà."

else

    info "Création de l'utilisateur '$ADMIN_USER'..."

    adduser "$ADMIN_USER"

    success "Utilisateur '$ADMIN_USER' créé."

fi

# ------------------------------------------------------------
# Ajout au groupe sudo
# ------------------------------------------------------------

info "Ajout de '$ADMIN_USER' au groupe sudo..."

usermod -aG sudo "$ADMIN_USER"

success "Utilisateur '$ADMIN_USER' ajouté au groupe sudo."

echo

# ------------------------------------------------------------
# Vérification de l'appartenance au groupe
# ------------------------------------------------------------

info "Vérification des groupes de '$ADMIN_USER'..."

id "$ADMIN_USER"

echo

if id -nG "$ADMIN_USER" | grep -qw sudo; then
    success "'$ADMIN_USER' appartient bien au groupe sudo."
else
    error "L'utilisateur n'appartient pas au groupe sudo."
    exit 1
fi

# ------------------------------------------------------------
# Vérification de la configuration sudo
# ------------------------------------------------------------

info "Vérification de la syntaxe sudo..."

if visudo -c; then
    success "La configuration sudo est valide."
else
    error "La configuration sudo contient une erreur."
    exit 1
fi

# ------------------------------------------------------------
# Résumé
# ------------------------------------------------------------

echo
echo "============================================================"
echo "                  RÉSUMÉ DE LA PHASE 1"
echo "============================================================"
echo

echo "Utilisateur administrateur : $ADMIN_USER"
echo "Groupe                    : sudo"

echo
success "Le compte administrateur est prêt."

warning "Déconnectez-vous puis reconnectez-vous avec '$ADMIN_USER'"
warning "afin que son appartenance au groupe sudo soit prise en compte."

echo
echo "Test à effectuer après reconnexion :"
echo
echo "    sudo whoami"
echo
echo "Résultat attendu : root"
echo

echo "============================================================"