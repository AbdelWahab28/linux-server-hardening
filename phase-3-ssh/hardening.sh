```bash
#!/bin/bash

# ============================================================
# Linux Server Hardening
# Phase 3 - Sécurisation de l'accès SSH
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

BACKUP_DIR="/var/backups/linux-server-hardening"
SSH_CONFIG="/etc/ssh/sshd_config"
SSH_BACKUP="$BACKUP_DIR/sshd_config.backup"

# Port SSH choisi pour le projet
SSH_PORT="2222"

# ------------------------------------------------------------
# Vérification sudo
# ------------------------------------------------------------

if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}[INFO]${NC} Script exécuté avec root."
else
    if ! sudo -v; then
        echo -e "${RED}[ERREUR]${NC} Privilèges sudo nécessaires."
        exit 1
    fi
fi

run_root()
{
    if [ "$EUID" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

echo
echo "=============================================="
echo " Phase 3 - Sécurisation SSH"
echo "=============================================="

# ------------------------------------------------------------
# 1. Installation OpenSSH
# ------------------------------------------------------------

echo
echo "[1/8] Vérification / installation d'OpenSSH..."

if ! command -v sshd >/dev/null 2>&1; then

    echo "OpenSSH Server n'est pas installé."

    if command -v apt >/dev/null 2>&1; then
        run_root apt update
        run_root apt install -y openssh-server
    else
        echo -e "${RED}[ERREUR]${NC} Gestionnaire APT indisponible."
        echo "Installez OpenSSH Server avec le gestionnaire de paquets"
        echo "de votre distribution avant de relancer ce script."
        exit 1
    fi

else
    echo -e "${GREEN}[OK]${NC} OpenSSH Server déjà installé."
fi

# ------------------------------------------------------------
# 2. Activation du service SSH
# ------------------------------------------------------------

echo
echo "[2/8] Vérification du service SSH..."

run_root systemctl enable ssh
run_root systemctl start ssh

if systemctl is-active --quiet ssh; then
    echo -e "${GREEN}[OK]${NC} Service SSH actif."
else
    echo -e "${RED}[ERREUR]${NC} Le service SSH n'est pas actif."
    exit 1
fi

# ------------------------------------------------------------
# 3. Sauvegarde de la configuration
# ------------------------------------------------------------

echo
echo "[3/8] Sauvegarde de la configuration SSH..."

run_root mkdir -p "$BACKUP_DIR"
run_root chmod 700 "$BACKUP_DIR"

if [ ! -f "$SSH_BACKUP" ]; then
    run_root cp "$SSH_CONFIG" "$SSH_BACKUP"
    echo -e "${GREEN}[OK]${NC} Sauvegarde créée : $SSH_BACKUP"
else
    echo -e "${YELLOW}[INFO]${NC} Une sauvegarde existe déjà."
fi

# ------------------------------------------------------------
# 4. Vérification de l'authentification par clé
# ------------------------------------------------------------

echo
echo "[4/8] Vérification de la configuration des clés SSH..."

CURRENT_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$CURRENT_USER" | cut -d: -f6)

if [ -f "$USER_HOME/.ssh/authorized_keys" ]; then
    echo -e "${GREEN}[OK]${NC} Clé publique trouvée pour $CURRENT_USER."
else
    echo -e "${YELLOW}[ATTENTION]${NC}"
    echo "Aucune clé publique trouvée pour $CURRENT_USER."
    echo
    echo "Avant de désactiver PasswordAuthentication,"
    echo "installez votre clé publique avec :"
    echo
    echo "ssh-copy-id utilisateur@adresse_ip_du_serveur"
    echo
    echo "Le script ne désactive donc pas encore l'authentification"
    echo "par mot de passe."
    exit 1
fi

# ------------------------------------------------------------
# 5. Désactivation root SSH
# ------------------------------------------------------------

echo
echo "[5/8] Désactivation de la connexion root SSH..."

run_root sed -i \
    -E 's/^[#[:space:]]*PermitRootLogin[[:space:]].*/PermitRootLogin no/' \
    "$SSH_CONFIG"

if ! grep -q "^PermitRootLogin no" "$SSH_CONFIG"; then
    echo "PermitRootLogin no" | run_root tee -a "$SSH_CONFIG" >/dev/null
fi

echo -e "${GREEN}[OK]${NC} Connexion root SSH désactivée."

# ------------------------------------------------------------
# 6. Désactivation mot de passe
# ------------------------------------------------------------

echo
echo "[6/8] Désactivation de l'authentification par mot de passe..."

run_root sed -i \
    -E 's/^[#[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication no/' \
    "$SSH_CONFIG"

if ! grep -q "^PasswordAuthentication no" "$SSH_CONFIG"; then
    echo "PasswordAuthentication no" | run_root tee -a "$SSH_CONFIG" >/dev/null
fi

run_root sed -i \
    -E 's/^[#[:space:]]*PubkeyAuthentication[[:space:]].*/PubkeyAuthentication yes/' \
    "$SSH_CONFIG"

if ! grep -q "^PubkeyAuthentication yes" "$SSH_CONFIG"; then
    echo "PubkeyAuthentication yes" | run_root tee -a "$SSH_CONFIG" >/dev/null
fi

echo -e "${GREEN}[OK]${NC} Authentification par mot de passe désactivée."

# ------------------------------------------------------------
# 7. Changement du port SSH
# ------------------------------------------------------------

echo
echo "[7/8] Configuration du port SSH : $SSH_PORT..."

run_root sed -i \
    -E "s/^[#[:space:]]*Port[[:space:]].*/Port $SSH_PORT/" \
    "$SSH_CONFIG"

if ! grep -q "^Port $SSH_PORT" "$SSH_CONFIG"; then
    echo "Port $SSH_PORT" | run_root tee -a "$SSH_CONFIG" >/dev/null
fi

echo -e "${GREEN}[OK]${NC} Port SSH configuré sur $SSH_PORT."

# ------------------------------------------------------------
# 8. Validation et rechargement
# ------------------------------------------------------------

echo
echo "[8/8] Validation de la configuration SSH..."

if run_root sshd -t; then

    echo -e "${GREEN}[OK]${NC} Configuration SSH valide."

    run_root systemctl reload ssh

    echo -e "${GREEN}[OK]${NC} Configuration SSH rechargée."

else

    echo -e "${RED}[ERREUR]${NC}"
    echo "La configuration SSH est invalide."
    echo "La configuration précédente est restaurée."

    run_root cp "$SSH_BACKUP" "$SSH_CONFIG"

    exit 1
fi

# ------------------------------------------------------------
# Résumé
# ------------------------------------------------------------

echo
echo "=============================================="
echo " Configuration SSH finale"
echo "=============================================="

run_root sshd -T | grep -E \
'^(port|permitrootlogin|passwordauthentication|pubkeyauthentication)'

echo
echo "Port en écoute :"
run_root ss -tlnp | grep ":$SSH_PORT" || true

echo
echo "=============================================="
echo -e "${GREEN} Phase 3 terminée ${NC}"
echo "=============================================="

echo
echo -e "${YELLOW}[IMPORTANT]${NC}"
echo "Testez immédiatement une nouvelle connexion SSH :"
echo
echo "ssh -p $SSH_PORT utilisateur@adresse_ip_du_serveur"
echo
echo "Ne fermez pas votre session actuelle avant d'avoir"
echo confirmé que la nouvelle connexion fonctionne."
```
