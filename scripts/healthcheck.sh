#!/usr/bin/env bash
# ==============================================================================
# Script : healthcheck.sh
# Rôle   : Diagnostic de santé complet de l'instance Replica 44
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [ ! -f "${ENV_FILE}" ]; then
    echo "[X] Fichier .env introuvable. Instance non amorcée."
    exit 1
fi

set -a; source "${ENV_FILE}"; set +a
INSTANCE_ID="${REPLICA44_INSTANCE_ID:-4000}"

echo "======================================================================"
echo "           REPLICA 44 - DIAGNOSTIC DE SANTÉ (INSTANCE ${INSTANCE_ID})"
echo "======================================================================"

# 1. Vérification des dossiers
DATA_DIR="${REPLICA44_DATA_DIR:-${HOME}/replica44-data-${INSTANCE_ID}}"
if [ -d "${DATA_DIR}" ]; then
    echo "[✓] Répertoire de données présent : ${DATA_DIR}"
else
    echo "[!] Répertoire de données manquant : ${DATA_DIR}"
fi

# 2. Vérification Podman Socket
if [ -S "/var/run/user/$(id -u)/podman/podman.sock" ]; then
    echo "[✓] Socket Podman actif et fonctionnel."
else
    echo "[!] Socket Podman inactif. Activez-le via: systemctl --user enable --now podman.socket"
fi

# 3. Vérification Statut Pod
POD_NAME="replica44-pod-${INSTANCE_ID}"
if command -v podman &>/dev/null; then
    if podman pod exists "${POD_NAME}" 2>/dev/null; then
        echo "[✓] Podman Pod '${POD_NAME}' existe et est configuré."
    else
        echo "[i] Pod '${POD_NAME}' non encore démarré (Démarrage : systemctl --user start ${POD_NAME})"
    fi
fi

# 4. Vérification Espace Disque (Seuil 80%)
if [ -f "${SCRIPT_DIR}/check_disk.sh" ]; then
    bash "${SCRIPT_DIR}/check_disk.sh"
fi

echo "======================================================================"
