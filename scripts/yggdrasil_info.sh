#!/usr/bin/env bash
# ==============================================================================
# Script : yggdrasil_info.sh
# Rôle   : Récupération automatique de l'IP IPv6 Yggdrasil du Pod Replica 44
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [ ! -f "${ENV_FILE}" ]; then
    echo "[X] Fichier .env introuvable."
    exit 1
fi

set -a; source "${ENV_FILE}"; set +a
INSTANCE_ID="${REPLICA44_INSTANCE_ID:-4000}"
CONTAINER_NAME="replica44-yggdrasil-${INSTANCE_ID}"

echo "[+] Extraction de l'adresse Yggdrasil IPv6 du conteneur ${CONTAINER_NAME}..."

if ! command -v podman &>/dev/null; then
    echo "[X] Podman non disponible."
    exit 1
fi

if podman container exists "${CONTAINER_NAME}" 2>/dev/null; then
    YGG_IP=$(podman exec "${CONTAINER_NAME}" ip -6 a show dev tun0 2>/dev/null | grep -i "inet6 2" | awk '{print $2}' | cut -d/ -f1 || true)
    if [ -z "${YGG_IP}" ]; then
        YGG_IP=$(podman exec "${CONTAINER_NAME}" yggdrasilctl getSelf 2>/dev/null | grep -i "IPv6 address" | awk '{print $3}' || true)
    fi
    if [ -n "${YGG_IP}" ]; then
        echo "======================================================================"
        echo " Adresse Yggdrasil IPv6 du Nœud : ${YGG_IP}"
        echo "======================================================================"
        echo " Pour synchroniser un autre nœud vers celui-ci :"
        echo "   ./configs/sync/sync_node.sh ${YGG_IP}"
    else
        echo "[i] Le conteneur Yggdrasil est en cours de démarrage ou non connecté."
    fi
else
    echo "[i] Conteneur Yggdrasil non démarré (systemctl --user start replica44-pod-${INSTANCE_ID})"
fi
