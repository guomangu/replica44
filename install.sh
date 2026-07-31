#!/usr/bin/env bash
# ==============================================================================
# Script : install.sh
# Rôle   : Installateur universel One-Liner VPS pour Replica 44
# Usage  : curl -fsSL https://raw.githubusercontent.com/guomangu/replica44/main/install.sh | bash
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

echo "======================================================================"
echo "          REPLICA 44 - INSTALLATEUR UNIVERSEL ONE-LINER               "
echo "======================================================================"

INSTALL_DIR="${INSTALL_DIR:-${HOME}/replica44-infra}"

if [ -f "./bootstrap.sh" ]; then
    INSTALL_DIR="$(pwd)"
elif [ -d "${INSTALL_DIR}" ]; then
    echo "[+] Dépôt existant détecté dans ${INSTALL_DIR}."
else
    echo "[+] Initialisation du projet Replica 44 dans ${INSTALL_DIR}..."
    git clone https://github.com/guomangu/replica44.git "${INSTALL_DIR}"
fi

cd "${INSTALL_DIR}"

if [ -f "./bootstrap.sh" ]; then
    bash ./bootstrap.sh
    bash ./scripts/deploy_quadlets.sh
    bash ./scripts/healthcheck.sh
else
    echo "[!] Exécution en mode local ou bootstrapping..."
fi

echo "======================================================================"
echo "[✓] INSTALLATION TERMINÉE AVEC SUCCÈS !"
echo "======================================================================"
