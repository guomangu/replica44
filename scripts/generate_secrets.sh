#!/usr/bin/env bash
# ==============================================================================
# Script : generate_secrets.sh
# Rôle   : Génération de secrets et allocation de tranches de 10 ports (Règle 1)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
ENV_EXAMPLE="${ROOT_DIR}/.env.example"

generate_random_secret() {
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32 || true
}

if [ ! -f "${ENV_FILE}" ]; then
    echo "[+] Recherche d'une tranche de 10 ports libres à partir de 4000..."
    BASE_PORT=$("${SCRIPT_DIR}/setup/find_free_port_block.sh")
    echo "[+] Tranche réservée avec succès ! Port de base : ${BASE_PORT}"

    cp "${ENV_EXAMPLE}" "${ENV_FILE}"
    sed -i "s|^BASE_PORT=.*|BASE_PORT=${BASE_PORT}|" "${ENV_FILE}"
    sed -i "s|^REPLICA44_INSTANCE_ID=.*|REPLICA44_INSTANCE_ID=${BASE_PORT}|" "${ENV_FILE}"
    sed -i "s|^REPLICA44_DATA_DIR=.*|REPLICA44_DATA_DIR=\${HOME}/replica44-data-${BASE_PORT}|" "${ENV_FILE}"
    sed -i "s|^REPLICA44_MEDIA_DIR=.*|REPLICA44_MEDIA_DIR=\${HOME}/replica44-data-${BASE_PORT}/torrents|" "${ENV_FILE}"
    sed -i "s|^GATEWAY_PORT=.*|GATEWAY_PORT=$(( BASE_PORT + 0 ))|" "${ENV_FILE}"
    sed -i "s|^JELLYFIN_PORT=.*|JELLYFIN_PORT=$(( BASE_PORT + 1 ))|" "${ENV_FILE}"
    sed -i "s|^TRANSMISSION_PORT=.*|TRANSMISSION_PORT=$(( BASE_PORT + 2 ))|" "${ENV_FILE}"
    sed -i "s|^YGGDRASIL_LISTEN_PORT=.*|YGGDRASIL_LISTEN_PORT=$(( BASE_PORT + 3 ))|" "${ENV_FILE}"
    sed -i "s|^VSCODE_PORT=.*|VSCODE_PORT=$(( BASE_PORT + 4 ))|" "${ENV_FILE}"
else
    echo "[i] Fichier .env existant détecté. Aucune modification apportée (protection anti-écrasement)."
fi

# GATEWAY_PASSWORD
if grep -q "^GATEWAY_PASSWORD=$" "${ENV_FILE}" || ! grep -q "^GATEWAY_PASSWORD=" "${ENV_FILE}"; then
    PASS=$(generate_random_secret)
    sed -i "s|^GATEWAY_PASSWORD=.*|GATEWAY_PASSWORD=${PASS}|" "${ENV_FILE}"
fi

# VSCODE_PASSWORD
if grep -q "^VSCODE_PASSWORD=$" "${ENV_FILE}" || ! grep -q "^VSCODE_PASSWORD=" "${ENV_FILE}"; then
    PASS=$(generate_random_secret)
    sed -i "s|^VSCODE_PASSWORD=.*|VSCODE_PASSWORD=${PASS}|" "${ENV_FILE}"
fi

# TRANSMISSION_PASSWORD
if grep -q "^TRANSMISSION_PASSWORD=$" "${ENV_FILE}" || ! grep -q "^TRANSMISSION_PASSWORD=" "${ENV_FILE}"; then
    PASS=$(generate_random_secret)
    sed -i "s|^TRANSMISSION_PASSWORD=.*|TRANSMISSION_PASSWORD=${PASS}|" "${ENV_FILE}"
fi

chmod 600 "${ENV_FILE}"
echo "[✓] Fichier .env configuré pour l'instance et sécurisé (droits 600)."
