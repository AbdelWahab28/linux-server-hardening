#!/bin/bash

# ============================================================
# Linux Server Hardening
# Phase 7 - Audit de sécurité et contrôle
# Outils : Lynis, Auditd, AIDE, RKHunter
# ============================================================

set -e

echo "=============================================="
echo " Phase 7 - Audit de sécurité"
echo "=============================================="

# Vérification root
if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être exécuté avec sudo."
    exit 1
fi

# ------------------------------------------------------------
# Détection de la distribution
# ------------------------------------------------------------

if [ ! -f /etc/os-release ]; then
    echo "[ERREUR] Impossible d'identifier la distribution."
    exit 1
fi

. /etc/os-release

echo "[INFO] Distribution détectée : $PRETTY_NAME"

# Vérification Debian
if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ] && [ "$ID_LIKE" != "debian" ]; then
    echo "[ERREUR] Cette phase nécessite une distribution basée sur Debian."
    exit 1
fi

# ------------------------------------------------------------
# Mise à jour de l'index
# ------------------------------------------------------------

echo
echo "[1/7] Mise à jour de l'index des paquets..."

apt update

# ------------------------------------------------------------
# Installation des outils
# ------------------------------------------------------------

echo
echo "[2/7] Installation des outils d'audit..."

apt install -y lynis auditd audispd-plugins aide rkhunter

# ------------------------------------------------------------
# Auditd
# ------------------------------------------------------------

echo
echo "[3/7] Vérification d'Auditd..."

systemctl enable auditd
systemctl start auditd

echo "[OK] État du service Auditd :"

systemctl is-active auditd

# ------------------------------------------------------------
# Règles Auditd
# ------------------------------------------------------------

echo
echo "[4/7] Installation des règles Auditd..."

RULES_FILE="/etc/audit/rules.d/hardening.rules"

if [ ! -f "$RULES_FILE" ]; then

    cat > "$RULES_FILE" << 'EOF'
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity

-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d -p wa -k sudoers

-w /etc/ssh/sshd_config -p wa -k ssh_config

-w /etc/hosts -p wa -k network
-w /etc/network -p wa -k network

-w /usr/bin/sudo -p x -k sudo_usage
-w /bin/su -p x -k su_usage
EOF

    echo "[OK] Règles Auditd créées."

else
    echo "[INFO] Le fichier $RULES_FILE existe déjà."
    echo "[INFO] Aucune modification effectuée."
fi

augenrules --load

echo
echo "[OK] Règles Auditd actuellement chargées :"

auditctl -l

# ------------------------------------------------------------
# AIDE
# ------------------------------------------------------------

echo
echo "[5/7] Vérification de la base AIDE..."

if [ ! -f /var/lib/aide/aide.db ]; then

    echo "[INFO] Aucune base AIDE détectée."
    echo "[INFO] Initialisation..."

    aideinit

    if [ -f /var/lib/aide/aide.db.new ]; then
        mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
        echo "[OK] Base AIDE créée."
    fi

else

    echo "[INFO] Une base AIDE existe déjà."
    echo "[INFO] Aucune réinitialisation effectuée."

fi

# ------------------------------------------------------------
# RKHunter
# ------------------------------------------------------------

echo
echo "[6/7] Mise à jour de RKHunter..."

rkhunter --update || true

echo
echo "[INFO] Vérification RKHunter..."

rkhunter --check --skip-keypress --report-warnings-only || true

# ------------------------------------------------------------
# Lynis
# ------------------------------------------------------------

echo
echo "[7/7] Lancement de l'audit Lynis..."

echo
echo "=============================================="
echo " Lancement de Lynis"
echo "=============================================="

lynis audit system

# ------------------------------------------------------------
# Fin
# ------------------------------------------------------------

echo
echo "=============================================="
echo " Phase 7 terminée"
echo "=============================================="

echo
echo "Journaux principaux :"

echo " - Lynis    : /var/log/lynis.log"
echo " - Auditd   : /var/log/audit/audit.log"
echo " - RKHunter : /var/log/rkhunter.log"

echo
echo "[IMPORTANT]"
echo "Analysez les résultats de Lynis, AIDE, Auditd"
echo "et RKHunter avant de considérer une alerte"
echo "comme étant réellement suspecte."

echo
echo "[OK] Audit terminé."