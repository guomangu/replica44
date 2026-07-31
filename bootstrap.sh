#!/usr/bin/env bash
# ==============================================================================
# Script : bootstrap.sh
# Rôle   : Point d'entrée d'amorçage universel Replica 44 (Phase 1 & 4)
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================================================"
echo "               REPLICA 44 - AMORÇAGE DE L'INFRASTRUCTURE             "
echo "======================================================================"

# 1. Détection de l'OS
source "${SCRIPT_DIR}/scripts/setup/detect_os.sh"

# 2. Génération des secrets (.env)
bash "${SCRIPT_DIR}/scripts/generate_secrets.sh"

# 3. Création des arborescences de données
bash "${SCRIPT_DIR}/scripts/setup/setup_dirs.sh"

# 4. Spécificités selon l'OS
case "${REPLICA44_OS}" in
    fedora|linux)
        bash "${SCRIPT_DIR}/scripts/setup/install_fedora.sh"
        ;;
    wsl)
        echo "[i] Environnement WSL2 détecté. Assurez-vous que podman est fonctionnel."
        ;;
    macos)
        echo "[i] macOS détecté. Utilisation de Podman Desktop / Machine requise."
        ;;
    *)
        echo "[!] OS non géré automatiquement."
        ;;
esac

# 5. Génération SSL Auto-signé
bash "${SCRIPT_DIR}/scripts/setup/setup_ssl.sh"

set -a; source "${SCRIPT_DIR}/.env"; set +a
GW_PORT="${GATEWAY_PORT:-4000}"

echo "======================================================================"
echo "[✓] INSTANCE REPLICA 44 PRÊTE !"
echo "----------------------------------------------------------------------"
echo " Accès au Dashboard HTTPS & Reverse Proxy :"
echo " 👉 https://localhost:${GW_PORT}"
echo "======================================================================"
