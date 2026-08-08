```bash
#!/bin/bash

# ============================================================
# Linux Server Hardening
# Phase 4 - Pare-feu UFW
# ============================================================

set -e

echo "=========================================="
echo " Phase 4 - Configuration du pare-feu UFW"
echo "=========================================="

# ------------------------------------------------------------
# Vérification des privilèges
# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être exécuté avec sudo."
    exit 1
fi

# ------------------------------------------------------------
# Installation de UFW
# ------------------------------------------------------------

if ! command -v ufw >/dev/null 2>&1; then
    echo "[+] UFW n'est pas installé."
    echo "[+] Installation de UFW..."

    apt update
    apt install -y ufw
else
    echo "[OK] UFW est déjà installé."
fi

# ------------------------------------------------------------
# Affichage de la configuration actuelle
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Configuration actuelle"
echo "=========================================="

ufw status verbose || true

# ------------------------------------------------------------
# Politique par défaut
# ------------------------------------------------------------

echo
echo "[+] Configuration de la politique par défaut..."

ufw default deny incoming
ufw default allow outgoing

# ------------------------------------------------------------
# Autorisation SSH
# ------------------------------------------------------------

echo
echo "[+] Autorisation du SSH..."

# Port SSH par défaut.
# Si le port SSH a été modifié lors de la phase 3,
# remplacer 22 par le port utilisé.
ufw allow 22/tcp

# ------------------------------------------------------------
# Journalisation
# ------------------------------------------------------------

echo
echo "[+] Activation de la journalisation UFW..."

ufw logging on

# ------------------------------------------------------------
# Activation du pare-feu
# ------------------------------------------------------------

echo
echo "[+] Activation du pare-feu..."

ufw --force enable

# ------------------------------------------------------------
# Affichage des règles
# ------------------------------------------------------------

echo
echo "=========================================="
echo " État du pare-feu"
echo "=========================================="

ufw status verbose

echo
echo "=========================================="
echo " Règles UFW"
echo "=========================================="

ufw status numbered

# ------------------------------------------------------------
# Vérification des ports en écoute
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Services réseau en écoute"
echo "=========================================="

ss -tulpn

echo
echo "=========================================="
echo " Phase 4 terminée"
echo "=========================================="

echo "[OK] UFW est configuré."
echo "[OK] Les connexions entrantes sont refusées par défaut."
echo "[OK] Les connexions sortantes sont autorisées."
echo "[OK] SSH est autorisé."
echo "[OK] La journalisation UFW est activée."
echo
echo "[IMPORTANT] Vérifiez que le port SSH correspond"
echo "au port réellement utilisé par votre serveur."
```
