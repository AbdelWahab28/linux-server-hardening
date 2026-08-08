```bash
#!/bin/bash

# ============================================================
# Linux Server Hardening
# Phase 6 - Kernel Hardening et paramètres réseau
# ============================================================

set -e

echo "=========================================="
echo " Phase 6 - Kernel Hardening"
echo "=========================================="

# ------------------------------------------------------------
# Vérification des privilèges
# ------------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être exécuté avec sudo."
    exit 1
fi

# ------------------------------------------------------------
# Fichier de configuration
# ------------------------------------------------------------

SYSCTL_FILE="/etc/sysctl.d/99-hardening.conf"

echo
echo "[+] Création de la configuration :"
echo "$SYSCTL_FILE"

cat > "$SYSCTL_FILE" << 'EOF'
# ============================================================
# Linux Server Hardening
# Kernel Hardening et paramètres réseau
# ============================================================

# ------------------------------------------------------------
# Désactivation du routage IPv4
# ------------------------------------------------------------

net.ipv4.ip_forward = 0

# ------------------------------------------------------------
# Désactivation des redirections ICMP
# ------------------------------------------------------------

net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# ------------------------------------------------------------
# Désactivation du source routing
# ------------------------------------------------------------

net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# ------------------------------------------------------------
# Reverse Path Filtering
# ------------------------------------------------------------

net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# ------------------------------------------------------------
# Protection ICMP
# ------------------------------------------------------------

net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# ------------------------------------------------------------
# Protection contre certaines attaques SYN
# ------------------------------------------------------------

net.ipv4.tcp_syncookies = 1
EOF

echo "[OK] Fichier de configuration créé."

# ------------------------------------------------------------
# Affichage de la configuration
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Configuration appliquée"
echo "=========================================="

cat "$SYSCTL_FILE"

# ------------------------------------------------------------
# Application des paramètres
# ------------------------------------------------------------

echo
echo "[+] Application des paramètres sysctl..."

sysctl --system

# ------------------------------------------------------------
# Vérification
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Vérification des paramètres"
echo "=========================================="

echo
echo "[+] IP Forwarding :"
sysctl net.ipv4.ip_forward

echo
echo "[+] Acceptation des redirections ICMP :"
sysctl net.ipv4.conf.all.accept_redirects
sysctl net.ipv4.conf.default.accept_redirects

echo
echo "[+] Envoi des redirections ICMP :"
sysctl net.ipv4.conf.all.send_redirects
sysctl net.ipv4.conf.default.send_redirects

echo
echo "[+] Source routing :"
sysctl net.ipv4.conf.all.accept_source_route
sysctl net.ipv4.conf.default.accept_source_route

echo
echo "[+] Reverse Path Filtering :"
sysctl net.ipv4.conf.all.rp_filter
sysctl net.ipv4.conf.default.rp_filter

echo
echo "[+] Protection ICMP :"
sysctl net.ipv4.icmp_echo_ignore_broadcasts
sysctl net.ipv4.icmp_ignore_bogus_error_responses

echo
echo "[+] SYN Cookies :"
sysctl net.ipv4.tcp_syncookies

# ------------------------------------------------------------
# Vérification réseau
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Interfaces réseau"
echo "=========================================="

ip a

echo
echo "=========================================="
echo " Table de routage"
echo "=========================================="

ip route

# ------------------------------------------------------------
# Fin
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Phase 6 terminée"
echo "=========================================="

echo "[OK] Paramètres du noyau configurés."
echo "[OK] Paramètres réseau durcis."
echo "[OK] Configuration persistante créée."
echo "[OK] Paramètres appliqués et vérifiés."

echo
echo "[ATTENTION]"
echo "Si ce serveur fonctionne comme routeur,"
echo "passerelle ou firewall, vérifiez la configuration"
echo "avant d'utiliser ces paramètres."
```