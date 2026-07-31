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

# 5. Génération SSL Auto-signé & htpasswd
bash "${SCRIPT_DIR}/scripts/setup/setup_ssl.sh"

# 6. Déploiement et activation des Quadlets systemd
bash "${SCRIPT_DIR}/scripts/deploy_quadlets.sh"

set -a; source "${SCRIPT_DIR}/.env"; set +a
INSTANCE_ID="${REPLICA44_INSTANCE_ID:-4000}"
GW_PORT="${GATEWAY_PORT:-4000}"

echo "[+] Démarrage automatique des conteneurs du Pod systemd..."
systemctl --user start "replica44-pod-${INSTANCE_ID}-pod" 2>/dev/null || true
systemctl --user start "${INSTANCE_ID}-landing.service" "${INSTANCE_ID}-jellyfin.service" "${INSTANCE_ID}-transmission.service" "${INSTANCE_ID}-vscode.service" "${INSTANCE_ID}-yggdrasil.service" 2>/dev/null || true

echo "======================================================================"
echo "[✓] REPLICA 44 DÉPLOYÉ ET OPÉRATIONNEL !"
echo "----------------------------------------------------------------------"
echo " 👉 Accès Dashboard HTTPS : https://localhost:${GW_PORT}"
echo " 🔑 Mot de passe Sync Gateway : ${GATEWAY_PASSWORD}"
echo " 🔑 Mot de passe Open VS Code : ${VSCODE_PASSWORD}"
echo " 🔑 Login Transmission : user='${TRANSMISSION_USER}', pass='${TRANSMISSION_PASSWORD}'"
echo "======================================================================"
