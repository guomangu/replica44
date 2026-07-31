#!/usr/bin/env bash
# ==============================================================================
# Script : uninstall.sh
# Rôle   : Suppression complète de l'instance Replica 44 sur l'hôte
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
QUADLET_DEST="${HOME}/.config/containers/systemd"

echo "======================================================================"
echo "                 REPLICA 44 - DÉSASTALLATION COMPLETE                  "
echo "======================================================================"

if [ -f "${ENV_FILE}" ]; then
    set -a; source "${ENV_FILE}"; set +a
    INSTANCE_ID="${REPLICA44_INSTANCE_ID:-4000}"
    POD_NAME="replica44-pod-${INSTANCE_ID}"

    echo "[+] Arrêt des services systemd..."
    systemctl --user stop "${POD_NAME}" 2>/dev/null || true

    echo "[+] Nettoyage des Quadlets systemd (${INSTANCE_ID})..."
    rm -f "${QUADLET_DEST}/replica44-pod-${INSTANCE_ID}.pod"
    rm -f "${QUADLET_DEST}/${INSTANCE_ID}-"*.container
    systemctl --user daemon-reload

    echo "[+] Nettoyage des règles pare-feu nftables..."
    sudo nft delete table inet "replica44_table_${INSTANCE_ID}" 2>/dev/null || true

    echo "[+] Suppression du fichier .env..."
    rm -f "${ENV_FILE}"
fi

echo "[✓] Nettoyage système accompli."
read -rp "[?] Voulez-vous TOUS les dossiers de données et médias ? (y/N): " choice
if [[ "${choice}" =~ ^[Yy]$ ]]; then
    rm -rf "${HOME}/replica44-data-"* 2>/dev/null || true
    echo "[✓] Répertoires de données supprimés."
else
    echo "[i] Les dossiers de données locaux ont été conservés."
fi
echo "======================================================================"
