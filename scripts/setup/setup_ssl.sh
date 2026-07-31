#!/usr/bin/env bash
# ==============================================================================
# Script : setup_ssl.sh
# Rôle   : Génération de certificat SSL auto-signé par défaut (HTTPS immédiat)
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if [ -f "${ROOT_DIR}/.env" ]; then
    set -a; source "${ROOT_DIR}/.env"; set +a
fi

INSTANCE_ID="${REPLICA44_INSTANCE_ID:-4000}"
DATA_DIR="${REPLICA44_DATA_DIR:-${HOME}/replica44-data-${INSTANCE_ID}}"
CERTS_DIR="${DATA_DIR}/config/gateway/certs"

mkdir -p "${CERTS_DIR}"

if [ ! -f "${CERTS_DIR}/replica44.crt" ] || [ ! -f "${CERTS_DIR}/replica44.key" ]; then
    echo "[+] Génération du certificat SSL auto-signé par défaut..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${CERTS_DIR}/replica44.key" \
        -out "${CERTS_DIR}/replica44.crt" \
        -subj "/C=FR/ST=State/L=City/O=Replica44/CN=localhost" 2>/dev/null || true
    echo "[✓] Certificats TLS/SSL générés dans ${CERTS_DIR}"
else
    echo "[i] Certificats SSL existants conservés (remplaçables par vos propres clés)."
fi

GATEWAY_PASS="${GATEWAY_PASSWORD:-admin}"
GATEWAY_CFG_DIR="${DATA_DIR}/config/gateway"
mkdir -p "${GATEWAY_CFG_DIR}"

if command -v openssl &>/dev/null; then
    CRYPT_PASS=$(openssl passwd -apr1 "${GATEWAY_PASS}")
    echo "admin:${CRYPT_PASS}" > "${GATEWAY_CFG_DIR}/htpasswd"
else
    echo "admin:${GATEWAY_PASS}" > "${GATEWAY_CFG_DIR}/htpasswd"
fi
chmod 644 "${GATEWAY_CFG_DIR}/htpasswd" 2>/dev/null || podman unshare chmod 644 "${GATEWAY_CFG_DIR}/htpasswd" 2>/dev/null || true
echo "[✓] Fichier d'authentification Gateway htpasswd généré pour l'utilisateur 'admin'."
