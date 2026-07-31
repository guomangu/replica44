#!/usr/bin/env bash
# ==============================================================================
# Script : sync_node.sh
# Rôle   : Synchronisation rsync inter-nœuds décentralisée à la demande
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

TARGET_IP="${1:-}"
REMOTE_USER="${2:-root}"

if [ -z "${TARGET_IP}" ]; then
    echo "Usage: $0 <IP_YGGDRASIL_DU_NOEUD_CIBLE> [UTILISATEUR_DISTANT]"
    echo "Exemple: $0 201:db8::1 root"
    exit 1
fi

# Clean IP format (remove tcp:// prefix or brackets if present)
TARGET_IP=$(echo "${TARGET_IP}" | sed -E 's|^[a-z]+://||; s|:[0-9]+$||; s|^\[||; s|\]$||')

if ! command -v rsync &>/dev/null; then
    echo "[!] rsync n'est pas installé. Tentative d'installation..."
    sudo apt-get update && sudo apt-get install -y rsync 2>/dev/null || sudo dnf install -y rsync 2>/dev/null || true
fi

DATA_DIR="${REPLICA44_DATA_DIR:-${HOME}/replica44-data}"

echo "[+] Test de connectivité vers [${TARGET_IP}]..."
if ! ping -c 1 -W 3 "${TARGET_IP}" &>/dev/null; then
    echo "[X] Erreur : L'hôte Yggdrasil distant [${TARGET_IP}] n'est pas joignable (Timeout / Hors ligne)."
    exit 2
fi

echo "[+] Synchronisation des médias terminés vers [${REMOTE_USER}@${TARGET_IP}]..."
if rsync -avz --progress \
    -e "ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no" \
    "${DATA_DIR}/torrents/completed/" \
    "${REMOTE_USER}@[${TARGET_IP}]:/home/${REMOTE_USER}/replica44-data/torrents/completed/"; then
    echo "[✓] Synchronisation terminée avec succès."
else
    echo "[X] Échec de la synchronisation vers ${TARGET_IP}."
    exit 3
fi
