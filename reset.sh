#!/usr/bin/env bash
# ==============================================================================
# Script : reset.sh
# Rôle   : Réinitialise les configurations SANS TOUCHER aux fichiers médias
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

echo "======================================================================"
echo "         REPLICA 44 - RÉINITIALISATION DES CONFIGURATIONS             "
echo "======================================================================"

if [ -f "${ENV_FILE}" ]; then
    set -a; source "${ENV_FILE}"; set +a
    INSTANCE_ID="${REPLICA44_INSTANCE_ID:-4000}"
    POD_NAME="replica44-pod-${INSTANCE_ID}"

    echo "[+] Arrêt du Pod systemd '${POD_NAME}'..."
    systemctl --user stop "${POD_NAME}" 2>/dev/null || true

    DATA_DIR="${REPLICA44_DATA_DIR:-${HOME}/replica44-data-${INSTANCE_ID}}"
    echo "[+] Suppression des configurations applicatives uniquement (Jellyfin/Transmission config)..."
    rm -rf "${DATA_DIR}/config" 2>/dev/null || true

    echo "[+] Suppression du fichier .env..."
    rm -f "${ENV_FILE}"
fi

echo "[✓] Configuration réinitialisée !"
echo "    [i] VOS FICHIERS ET MÉDIAS DANS /torrents ONT ÉTÉ CONSERVÉS."
echo "    Vous pouvez relancer ./bootstrap.sh pour reconfigurer le projet."
echo "======================================================================"
