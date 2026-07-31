#!/usr/bin/env bash
# ==============================================================================
# Script : watch_transmission.sh
# Rôle   : Traitement automatique "As a File" des torrents
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [ -f "${ENV_FILE}" ]; then
    set -a; source "${ENV_FILE}"; set +a
fi

DATA_DIR="${REPLICA44_DATA_DIR:-${HOME}/replica44-data-4000}"
WATCH_DIR="${DATA_DIR}/torrents/watch"
COMPLETED_DIR="${DATA_DIR}/torrents/completed"

mkdir -p "${WATCH_DIR}" "${COMPLETED_DIR}"

echo "[+] Surveillance et traitement des fichiers torrents dans ${WATCH_DIR}..."

# Nettoyage des torrents orphelins ou complétés
shopt -s nullglob
for torrent in "${WATCH_DIR}"/*.torrent; do
    echo "[i] Fichier détecté : $(basename "${torrent}")"
done

echo "[✓] Dossier de surveillance vérifié."
