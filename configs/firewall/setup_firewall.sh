#!/usr/bin/env bash
# ==============================================================================
# Script : setup_firewall.sh
# Rôle   : Isolation pare-feu nftables dédiée (Zéro impact hôte global)
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [ -f "${ENV_FILE}" ]; then
    set -a; source "${ENV_FILE}"; set +a
fi

INSTANCE_ID="${REPLICA44_INSTANCE_ID:-4000}"
TABLE_NAME="replica44_table_${INSTANCE_ID}"

echo "[+] Application des règles pare-feu isolees (${TABLE_NAME})..."

if ! command -v nft &>/dev/null; then
    echo "[!] nftables non présent. Skip pare-feu (impact nul hôte)."
    exit 0
fi

# Création d'une table dédiée isolée sans altérer les règles globales de l'hôte
sudo nft add table inet "${TABLE_NAME}" 2>/dev/null || true
sudo nft flush table inet "${TABLE_NAME}" 2>/dev/null || true

# Chaîne d'entrée dédiée avec hook input prioritaire
sudo nft add chain inet "${TABLE_NAME}" pod_input '{ type filter hook input priority 0; policy accept; }'

# Restriction de l'IDE VS Code aux connexions locales / sécurisées uniquement
if [ -n "${VSCODE_PORT:-}" ]; then
    sudo nft add rule inet "${TABLE_NAME}" pod_input tcp dport "${VSCODE_PORT}" ip saddr != 127.0.0.1 drop 2>/dev/null || true
fi

echo "[✓] Table pare-feu '${TABLE_NAME}' configurée (seuls les ports du Pod sont filtrés)."
