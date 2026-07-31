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
    echo "[1/3] Dépôt existant détecté dans ${INSTALL_DIR}."
else
    echo "[1/3] Récupération de l'infrastructure Replica 44 depuis GitHub..."
    git clone https://github.com/guomangu/replica44.git "${INSTALL_DIR}"
fi

cd "${INSTALL_DIR}"

echo "[2/3] Configuration automatique & Amorçage de l'instance..."
bash ./bootstrap.sh

echo "[3/3] Contrôle de santé de l'instance..."
bash ./scripts/healthcheck.sh || true

echo "======================================================================"
echo "[✓] INSTALLATION ET DÉPLOIEMENT TERMINÉS EN 1 CLIC !"
echo "======================================================================"
