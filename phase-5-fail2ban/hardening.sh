```bash
#!/bin/bash

# ============================================================
# Linux Server Hardening
# Phase 5 - Protection contre les attaques brute force
# Fail2ban
# ============================================================

set -e

echo "=========================================="
echo " Phase 5 - Configuration de Fail2ban"
echo "=========================================="

# ------------------------------------------------------------
# Vérification des privilèges
# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être exécuté avec sudo."
    exit 1
fi

# ------------------------------------------------------------
# Installation de Fail2ban
# ------------------------------------------------------------

if ! command -v fail2ban-client >/dev/null 2>&1; then
    echo "[+] Fail2ban n'est pas installé."
    echo "[+] Installation..."

    apt update
    apt install -y fail2ban
else
    echo "[OK] Fail2ban est déjà installé."
fi

# ------------------------------------------------------------
# Activation du démarrage automatique
# ------------------------------------------------------------

echo
echo "[+] Activation du démarrage automatique..."

systemctl enable fail2ban

# ------------------------------------------------------------
# Création de la configuration locale
# ------------------------------------------------------------

JAIL_LOCAL="/etc/fail2ban/jail.local"

if [ ! -f "$JAIL_LOCAL" ]; then

    echo
    echo "[+] Création de $JAIL_LOCAL..."

    cat > "$JAIL_LOCAL" << 'EOF'
[DEFAULT]

# Durée du bannissement
bantime = 24h

# Fenêtre de temps pendant laquelle les tentatives sont comptabilisées
findtime = 10m

# Nombre maximum de tentatives avant bannissement
maxretry = 3

#Utiliser ufw pour bloquer
banaction= ufw

[sshd]

enabled = true

# Port SSH.
# Adapter cette valeur si le port SSH a été modifié.
port = ssh
filter= sshd
logpath= /var/log/auth.log

# Utilisation des journaux systemd
backend = systemd
EOF

else

    echo
    echo "[INFO] $JAIL_LOCAL existe déjà."
    echo "[INFO] La configuration existante est conservée."

fi

# ------------------------------------------------------------
# Vérification de la configuration
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Vérification de la configuration"
echo "=========================================="

fail2ban-client -t

# ------------------------------------------------------------
# Démarrage / redémarrage du service
# ------------------------------------------------------------

echo
echo "[+] Redémarrage de Fail2ban..."

systemctl restart fail2ban

# ------------------------------------------------------------
# Vérification du service
# ------------------------------------------------------------

echo
echo "=========================================="
echo " État du service"
echo "=========================================="

systemctl --no-pager status fail2ban

# ------------------------------------------------------------
# Vérification des jails
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Jails actives"
echo "=========================================="

fail2ban-client status

# ------------------------------------------------------------
# Vérification de la jail SSH
# ------------------------------------------------------------

echo
echo "=========================================="
echo " État de la protection SSH"
echo "=========================================="

if fail2ban-client status sshd >/dev/null 2>&1; then
    fail2ban-client status sshd
else
    echo "[ATTENTION] La jail sshd n'est pas disponible."
    echo "Vérifiez la configuration de Fail2ban."
fi

# ------------------------------------------------------------
# Fin
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Phase 5 terminée"
echo "=========================================="

echo "[OK] Fail2ban est installé."
echo "[OK] Le service est activé."
echo "[OK] La protection SSH est configurée."
echo "[OK] Les paramètres de détection sont appliqués."
echo
echo "[IMPORTANT] Vérifiez que le port SSH configuré"
echo "dans jail.local correspond au port réel de SSH."
```
