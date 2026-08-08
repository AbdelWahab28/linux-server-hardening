```bash
#!/bin/bash

# ============================================================
# Linux Server Hardening
# Phase 2 - Gestion des comptes et des privileges
#
# Systeme cible :
#   Linux base Debian
#
# Objectifs :
#   - Verifier le compte root
#   - Verifier l'existence de sudo
#   - Creer un compte administratif si necessaire
#   - Ajouter l'utilisateur au groupe sudo
#   - Verifier l'acces sudo
#
# IMPORTANT :
#   La configuration SSH n'est PAS realisee dans cette phase.
# ============================================================

set -e

# ------------------------------------------------------------
# Couleurs
# ------------------------------------------------------------

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ------------------------------------------------------------
# Fonctions
# ------------------------------------------------------------

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

# ------------------------------------------------------------
# Verification root
# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    error "Ce script doit etre execute avec les privileges root."
    echo "Utilisation : sudo ./hardening.sh"
    exit 1
fi

info "Privileges root confirmes."

# ------------------------------------------------------------
# Verification du compte root
# ------------------------------------------------------------

echo
info "Verification du compte root..."

if id root >/dev/null 2>&1; then
    info "Le compte root existe."

    ROOT_UID=$(id -u root)

    if [ "$ROOT_UID" -eq 0 ]; then
        info "Le compte root possede bien l'UID 0."
    else
        error "Le compte root ne possede pas l'UID 0."
        exit 1
    fi
else
    error "Le compte root est introuvable."
    exit 1
fi

# ------------------------------------------------------------
# Verification de sudo
# ------------------------------------------------------------

echo
info "Verification de sudo..."

if command -v sudo >/dev/null 2>&1; then
    info "sudo est deja installe."
else
    warning "sudo n'est pas installe."

    if command -v apt >/dev/null 2>&1; then
        info "Installation de sudo..."
        apt update
        apt install -y sudo
    else
        error "Le gestionnaire de paquets apt est introuvable."
        error "Installation automatique de sudo impossible."
        exit 1
    fi
fi

# ------------------------------------------------------------
# Verification du groupe sudo
# ------------------------------------------------------------

echo
info "Verification du groupe sudo..."

if getent group sudo >/dev/null 2>&1; then
    info "Le groupe sudo existe."
else
    warning "Le groupe sudo n'existe pas."

    info "Creation du groupe sudo..."
    groupadd sudo
fi

# ------------------------------------------------------------
# Demande du nom du compte administratif
# ------------------------------------------------------------

echo
read -r -p "Nom du compte administratif a utiliser : " ADMIN_USER

if [ -z "$ADMIN_USER" ]; then
    error "Aucun nom d'utilisateur fourni."
    exit 1
fi

# ------------------------------------------------------------
# Verification de l'utilisateur
# ------------------------------------------------------------

echo
info "Verification du compte ${ADMIN_USER}..."

if id "$ADMIN_USER" >/dev/null 2>&1; then

    info "Le compte ${ADMIN_USER} existe deja."

else

    warning "Le compte ${ADMIN_USER} n'existe pas."

    info "Creation du compte ${ADMIN_USER}..."

    adduser "$ADMIN_USER"

    info "Compte ${ADMIN_USER} cree."
fi

# ------------------------------------------------------------
# Ajout au groupe sudo
# ------------------------------------------------------------

echo
info "Ajout de ${ADMIN_USER} au groupe sudo..."

usermod -aG sudo "$ADMIN_USER"

info "${ADMIN_USER} a ete ajoute au groupe sudo."

# ------------------------------------------------------------
# Verification des groupes
# ------------------------------------------------------------

echo
info "Verification des groupes de ${ADMIN_USER}..."

id "$ADMIN_USER"

if id -nG "$ADMIN_USER" | grep -qw sudo; then
    info "Le compte ${ADMIN_USER} appartient bien au groupe sudo."
else
    error "Le compte ${ADMIN_USER} n'appartient pas au groupe sudo."
    exit 1
fi

# ------------------------------------------------------------
# Verification de la configuration sudo
# ------------------------------------------------------------

echo
info "Verification de la configuration sudo..."

if visudo -c; then
    info "La configuration sudo est valide."
else
    error "Une erreur a ete detectee dans la configuration sudo."
    exit 1
fi

# ------------------------------------------------------------
# Verification finale
# ------------------------------------------------------------

echo
info "Verification finale..."

echo
echo "Utilisateur administratif : $ADMIN_USER"
echo "UID : $(id -u "$ADMIN_USER")"
echo "Groupes : $(id -nG "$ADMIN_USER")"

echo

if id -nG "$ADMIN_USER" | grep -qw sudo; then
    info "Configuration du compte administratif terminee."
else
    error "La configuration du compte administratif a echoue."
    exit 1
fi

# ------------------------------------------------------------
# Test sudo
# ------------------------------------------------------------

echo
warning "Le test sudo doit etre effectue depuis une nouvelle session utilisateur."

echo
echo "Connectez-vous avec :"
echo
echo "    su - $ADMIN_USER"
echo
echo "Puis executez :"
echo
echo "    sudo whoami"
echo
echo "Le resultat attendu est :"
echo
echo "    root"
echo

# ------------------------------------------------------------
# Fin
# ------------------------------------------------------------

info "Phase 2 terminee avec succes."

echo
echo "============================================================"
echo " Phase 2 - Gestion des comptes et privileges"
echo " Etat : TERMINE"
echo "============================================================"
```
