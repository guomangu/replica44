#!/usr/bin/env bash
# ==============================================================================
# Script : deploy_quadlets.sh
# Rôle   : Substitution et déploiement des Quadlets (Règle 1 < 100 lignes)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
QUADLET_DEST="${HOME}/.config/containers/systemd"

if [ ! -f "${ENV_FILE}" ]; then
    echo "[X] Fichier .env manquant. Exécutez ./bootstrap.sh d'abord."
    exit 1
fi

set -a; source "${ENV_FILE}"; set +a

INSTANCE_ID="${REPLICA44_INSTANCE_ID:-4000}"
MEDIA_DIR="${REPLICA44_MEDIA_DIR:-${HOME}/replica44-data-${INSTANCE_ID}/torrents}"
mkdir -p "${QUADLET_DEST}"

echo "[+] Instanciation des Quadlets pour l'instance ${INSTANCE_ID}..."

# Nettoyage des Quadlets isolés de l'instance
rm -f "${QUADLET_DEST}/replica44-pod-"*.pod
rm -f "${QUADLET_DEST}/"*"-jellyfin.container"
rm -f "${QUADLET_DEST}/"*"-transmission.container"
rm -f "${QUADLET_DEST}/"*"-vscode.container"
rm -f "${QUADLET_DEST}/"*"-yggdrasil.container"
rm -f "${QUADLET_DEST}/"*"-landing.container"

# Substitution du Pod
sed "s/\${REPLICA44_INSTANCE_ID}/${INSTANCE_ID}/g; \
     s/\${GATEWAY_PORT}/${GATEWAY_PORT:-4000}/g; \
     s/\${VSCODE_PORT}/${VSCODE_PORT:-4004}/g; \
     s/\${JELLYFIN_PORT}/${JELLYFIN_PORT:-4001}/g; \
     s/\${TRANSMISSION_PORT}/${TRANSMISSION_PORT:-4002}/g" \
     "${ROOT_DIR}/configs/systemd/replica44.pod" > "${QUADLET_DEST}/replica44-pod-${INSTANCE_ID}.pod"

# Substitution des Conteneurs
for cfile in "${ROOT_DIR}"/configs/systemd/*.container; do
    cname=$(basename "${cfile}")
    sed "s/\${REPLICA44_INSTANCE_ID}/${INSTANCE_ID}/g; \
         s/\${TRANSMISSION_USER}/${TRANSMISSION_USER:-replica}/g; \
         s/\${TRANSMISSION_PASSWORD}/${TRANSMISSION_PASSWORD:-}/g; \
         s/\${VSCODE_PASSWORD}/${VSCODE_PASSWORD:-}/g; \
         s|\${REPLICA44_INFRA_DIR}|${ROOT_DIR}|g; \
         s|\${REPLICA44_DATA_DIR}|${REPLICA44_DATA_DIR:-${HOME}/replica44-data-${INSTANCE_ID}}|g; \
         s|%h/replica44-infra/.env|${ENV_FILE}|g; \
         s|%h/Musique/replica/.env|${ENV_FILE}|g; \
         s|\${REPLICA44_MEDIA_DIR}|${MEDIA_DIR}|g" \
         "${cfile}" > "${QUADLET_DEST}/${INSTANCE_ID}-${cname}"
done

echo "[+] Rechargement systemd..."
systemctl --user daemon-reload

echo "[✓] Quadlets déployés dans ${QUADLET_DEST}."
echo "    Pour démarrer le Pod systemd : systemctl --user start replica44-pod-${INSTANCE_ID}-pod"
