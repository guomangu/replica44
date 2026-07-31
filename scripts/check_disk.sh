#!/usr/bin/env bash
# ==============================================================================
# Script : check_disk.sh
# Rôle   : Surveillance de l'espace disque avec alerte à 80% (Sans suppression)
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [ -f "${ENV_FILE}" ]; then
    set -a; source "${ENV_FILE}"; set +a
fi

INSTANCE_ID="${REPLICA44_INSTANCE_ID:-4000}"
DATA_DIR="${REPLICA44_DATA_DIR:-${HOME}/replica44-data-${INSTANCE_ID}}"
THRESHOLD=80

echo "[+] Vérification du taux d'occupation du disque pour ${DATA_DIR}..."

USAGE_PCT=$(df -P "${DATA_DIR}" | awk 'NR==2 {gsub("%",""); print $5}')
AVAIL_GB=$(df -P -h "${DATA_DIR}" | awk 'NR==2 {print $4}')

echo "  -> Occupation actuelle : ${USAGE_PCT}% (Libre : ${AVAIL_GB})"

if [ "${USAGE_PCT}" -ge "${THRESHOLD}" ]; then
    echo "======================================================================"
    echo "[!] ALERTE CRITIQUE DISQUE : ${USAGE_PCT}% d'occupation !"
    echo "[!] Seuil de sécurité de ${THRESHOLD}% dépassé sur le VPS."
    echo "[!] Veuillez faire du tri dans votre dossier de téléchargement."
    echo "======================================================================"
else
    echo "[✓] Espace disque optimal (< ${THRESHOLD}% d'occupation)."
fi
