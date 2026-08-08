```bash
#!/bin/bash

# ============================================================
# Linux Server Hardening
# Phase 2 - Préparation et configuration administrative
# ============================================================

set -e

# ------------------------------------------------------------
# Couleurs
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ------------------------------------------------------------
# Vérification root / sudo
# ------------------------------------------------------------

if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}[INFO]${NC} Script exécuté directement avec root."
else
    if ! sudo -v; then
        echo -e "${RED}[ERREUR]${NC} L'utilisateur ne possède pas les privilèges sudo."
        exit 1
    fi

    echo -e "${GREEN}[OK]${NC} Accès sudo vérifié."
fi

# ------------------------------------------------------------
# Variables
# ------------------------------------------------------------

BACKUP_DIR="/var/backups/linux-server-hardening"
UMASK_FILE="/etc/profile.d/hardening-umask.sh"
SUDO_CONFIG="/etc/sudoers.d/hardening"

# Fonction sudo compatible root/non-root
run_root()
{
    if [ "$EUID" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# ------------------------------------------------------------
# Informations sur le compte courant
# ------------------------------------------------------------

echo
echo "=============================================="
echo "  Compte administratif"
echo "=============================================="

echo "Utilisateur : $(whoami)"
echo "Identité    : $(id)"

# ------------------------------------------------------------
# Création du répertoire de sauvegarde
# ------------------------------------------------------------

echo
echo "[1/6] Préparation du répertoire de sauvegarde..."

run_root mkdir -p "$BACKUP_DIR"
run_root chown root:root "$BACKUP_DIR"
run_root chmod 700 "$BACKUP_DIR"

echo -e "${GREEN}[OK]${NC} $BACKUP_DIR"

# ------------------------------------------------------------
# Configuration du umask
# ------------------------------------------------------------

echo
echo "[2/6] Configuration du umask..."

run_root tee "$UMASK_FILE" > /dev/null <<EOF
# Linux Server Hardening
# Umask restrictif pour les nouvelles sessions
umask 027
EOF

run_root chown root:root "$UMASK_FILE"
run_root chmod 644 "$UMASK_FILE"

echo -e "${GREEN}[OK]${NC} umask 027 configuré."

# ------------------------------------------------------------
# Configuration sudo
# ------------------------------------------------------------

echo
echo "[3/6] Configuration du délai sudo..."

run_root tee "$SUDO_CONFIG" > /dev/null <<EOF
# Linux Server Hardening
# Demande à nouveau le mot de passe sudo après 5 minutes
Defaults timestamp_timeout=5
EOF

run_root chown root:root "$SUDO_CONFIG"
run_root chmod 440 "$SUDO_CONFIG"

# Vérification avant de continuer
if run_root visudo -cf "$SUDO_CONFIG" > /dev/null; then
    echo -e "${GREEN}[OK]${NC} Configuration sudo valide."
else
    echo -e "${RED}[ERREUR]${NC} Configuration sudo invalide."
    exit 1
fi

# ------------------------------------------------------------
# Sécurisation des fichiers utilisateurs
# ------------------------------------------------------------

echo
echo "[4/6] Vérification des permissions des fichiers sensibles..."

run_root chmod 644 /etc/passwd
run_root chmod 644 /etc/group
run_root chmod 640 /etc/shadow
run_root chmod 640 /etc/gshadow

run_root chown root:root /etc/passwd
run_root chown root:root /etc/group

# Le groupe shadow peut ne pas exister sur certaines
# distributions Debian dérivées.
if getent group shadow > /dev/null 2>&1; then
    run_root chown root:shadow /etc/shadow
    run_root chown root:shadow /etc/gshadow
fi

echo -e "${GREEN}[OK]${NC} Permissions vérifiées."

# ------------------------------------------------------------
# Vérification globale de sudo
# ------------------------------------------------------------

echo
echo "[5/6] Vérification de la configuration sudo..."

if run_root visudo -cf /etc/sudoers > /dev/null; then
    echo -e "${GREEN}[OK]${NC} /etc/sudoers est valide."
else
    echo -e "${RED}[ERREUR]${NC} /etc/sudoers contient une erreur."
    exit 1
fi

# ------------------------------------------------------------
# Vérification finale
# ------------------------------------------------------------

echo
echo "[6/6] Vérification finale..."

echo
echo "Utilisateur : $(whoami)"
echo "UID/GID     : $(id)"

echo
echo "Répertoire de sauvegarde :"
ls -ld "$BACKUP_DIR"

echo
echo "Configuration sudo :"
ls -l "$SUDO_CONFIG"

echo
echo "Configuration umask :"
ls -l "$UMASK_FILE"

echo
echo "Permissions fichiers sensibles :"
ls -l /etc/passwd /etc/group /etc/shadow /etc/gshadow

# ------------------------------------------------------------
# Fin
# ------------------------------------------------------------

echo
echo "=============================================="
echo -e "${GREEN} Phase 2 terminée avec succès ${NC}"
echo "=============================================="

echo
echo "Préparation administrative terminée."
echo "Le système est prêt pour la Phase 3 : SSH."
echo
```