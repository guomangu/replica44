#!/usr/bin/env bash
# ==============================================================================
# Script : setup_dirs.sh
# Rôle   : Arborescence et personnalisation stockage média (Règle 1)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if [ -f "${ROOT_DIR}/.env" ]; then
    set -a; source "${ROOT_DIR}/.env"; set +a
fi

INSTANCE_ID="${REPLICA44_INSTANCE_ID:-4000}"
DATA_DIR="${REPLICA44_DATA_DIR:-${HOME}/replica44-data-${INSTANCE_ID}}"
MEDIA_DIR="${REPLICA44_MEDIA_DIR:-${DATA_DIR}/torrents}"

echo "[+] Création des arborescences de données..."

# 1. Dossier média personnalisé / lourd (watch & completed)
mkdir -p "${MEDIA_DIR}/watch" "${MEDIA_DIR}/completed" "${DATA_DIR}/ide_workspace"
chmod -R 777 "${MEDIA_DIR}" "${DATA_DIR}/ide_workspace" 2>/dev/null || podman unshare chmod -R 777 "${MEDIA_DIR}" "${DATA_DIR}/ide_workspace" 2>/dev/null || true

# Assurer l'accès en lecture (755) pour Nginx sur l'arborescence des données
chmod 755 "${DATA_DIR}" 2>/dev/null || podman unshare chmod 755 "${DATA_DIR}" 2>/dev/null || true

# 2. Dossiers Configurations
JELLYFIN_CFG="${DATA_DIR}/config/jellyfin/config"
TRANSMISSION_CFG="${DATA_DIR}/config/transmission"
GATEWAY_CFG="${DATA_DIR}/config/gateway/html"
CERTS_CFG="${DATA_DIR}/config/gateway/certs"

mkdir -p "${JELLYFIN_CFG}" "${TRANSMISSION_CFG}" "${GATEWAY_CFG}" "${CERTS_CFG}"

# 3. Injection pré-configurations si non existantes
if [ ! -f "${TRANSMISSION_CFG}/settings.json" ]; then
    cp "${ROOT_DIR}/configs/transmission/settings.json" "${TRANSMISSION_CFG}/settings.json"
fi

cp "${ROOT_DIR}/configs/gateway/index.html" "${GATEWAY_CFG}/index.html"
cp "${ROOT_DIR}/configs/gateway/services.json" "${GATEWAY_CFG}/services.json"

sed "s/SERVER_DOMAIN/${SERVER_DOMAIN:-localhost}/g; \
     s/4000/${GATEWAY_PORT:-4000}/g; \
     s/4001/${JELLYFIN_PORT:-4001}/g; \
     s/4002/${TRANSMISSION_PORT:-4002}/g; \
     s/4004/${VSCODE_PORT:-4004}/g" \
     "${ROOT_DIR}/configs/gateway/nginx.conf" > "${DATA_DIR}/config/gateway/nginx.conf"

chmod -R 755 "${DATA_DIR}/config/gateway" 2>/dev/null || podman unshare chmod -R 755 "${DATA_DIR}/config/gateway" 2>/dev/null || true
chmod 644 "${GATEWAY_CFG}/index.html" "${GATEWAY_CFG}/services.json" "${DATA_DIR}/config/gateway/nginx.conf" 2>/dev/null || true

echo "[✓] Répertoires initialisés. Dossier média : ${MEDIA_DIR}"
