#!/bin/bash

# ============================================================
# Linux Server Hardening
# Phase 0 — Préparation et état initial du serveur
# Compatible avec les distributions basées sur Debian
# ============================================================

set -e

# ------------------------------------------------------------
# Couleurs
# ------------------------------------------------------------
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
    error "Impossible d'identifier la distribution Linux."
    exit 1
fi

source /etc/os-release

if [ "$ID" != "debian" ] && [ "$ID_LIKE" != *"debian"* ]; then
    error "Cette phase nécessite une distribution basée sur Debian."
    exit 1
fi

echo
echo "============================================================"
echo "        LINUX SERVER HARDENING — PHASE 0"
echo "        Préparation et état initial du serveur"
echo "============================================================"
echo

# ------------------------------------------------------------
# 1. Version du système
# ------------------------------------------------------------
info "Version du système :"

if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -a
else
    echo "$PRETTY_NAME"
    warning "lsb_release n'est pas installé."
fi

echo

# ------------------------------------------------------------
# 2. Vérification du noyau Linux
# ------------------------------------------------------------
info "Noyau Linux :"
uname -r

echo

# ------------------------------------------------------------
# 3. Nom de la machine
# ------------------------------------------------------------
info "Nom de la machine :"
hostname

echo

# ------------------------------------------------------------
# 4. Adresse IP et routage
# ------------------------------------------------------------
info "Configuration IP :"
ip a

echo
info "Table de routage :"
ip route

echo

# ------------------------------------------------------------
# 5. Interfaces réseau
# ------------------------------------------------------------
info "Interfaces réseau :"
ip -br link

echo

# ------------------------------------------------------------
# 6. Utilisateurs
# ------------------------------------------------------------
info "Utilisateurs présents sur le système :"
cat /etc/passwd

echo

# ------------------------------------------------------------
# 7. Groupes
# ------------------------------------------------------------
info "Groupes présents sur le système :"
cat /etc/group

echo

# ------------------------------------------------------------
# 8. Services actifs
# ------------------------------------------------------------
info "Services actuellement actifs :"
systemctl --type=service --state=running

echo

# ------------------------------------------------------------
# 9. Ports ouverts
# ------------------------------------------------------------
info "Ports actuellement ouverts et services en écoute :"
ss -tulpn

echo

# ------------------------------------------------------------
# 10. Mise à jour de l'index des paquets
# ------------------------------------------------------------
info "Mise à jour de l'index des paquets..."

apt update

success "Index des paquets mis à jour."

echo

# ------------------------------------------------------------
# 11. Mise à jour du système
# ------------------------------------------------------------
info "Mise à jour du système..."

apt upgrade -y

success "Système mis à jour."


echo

# ------------------------------------------------------------
# 12. Vérification de unattended-upgrades
# ------------------------------------------------------------
info "Vérification de la gestion des mises à jour automatiques..."

if dpkg -l unattended-upgrades 2>/dev/null | grep -q '^ii'; then
    success "unattended-upgrades est déjà installé."
else
    warning "unattended-upgrades n'est pas installé."
    info "Installation de unattended-upgrades..."

    apt install -y unattended-upgrades

    success "unattended-upgrades installé."
fi

echo

info "Configuration de unattended-upgrades..."

dpkg-reconfigure unattended-upgrades

echo

# ------------------------------------------------------------
# 13. Redémarrage
# ------------------------------------------------------------
warning "Le système a été mis à jour."

echo
echo "Un redémarrage est recommandé afin de charger"
echo "les éventuelles mises à jour du noyau."

read -rp "Redémarrer maintenant ? [o/N] : " REBOOT

if [[ "$REBOOT" =~ ^[oO][uU][iI]$|^[oO]$ ]]; then
    info "Redémarrage du serveur..."
    reboot
else
    warning "Redémarrage reporté."
fi