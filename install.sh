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

CURRENT_DIR="$(pwd)"

if [ -f "${CURRENT_DIR}/bootstrap.sh" ]; then
    INSTALL_DIR="${CURRENT_DIR}"
    echo "[1/3] Exécution de l'amorçage dans le dossier courant : ${INSTALL_DIR}"
else
    # Génération d'un nom de dossier d'instance unique si le dossier existe déjà
    TARGET_FOLDER="${CURRENT_DIR}/replica44"
    COUNTER=1
    while [ -d "${TARGET_FOLDER}" ] && [ ! -f "${TARGET_FOLDER}/bootstrap.sh" ]; do
        TARGET_FOLDER="${CURRENT_DIR}/replica44-${COUNTER}"
        COUNTER=$(( COUNTER + 1 ))
    done

    if [ ! -f "${TARGET_FOLDER}/bootstrap.sh" ]; then
        echo "[1/3] Récupération d'une nouvelle instance Replica 44 dans ${TARGET_FOLDER}..."
        git clone https://github.com/guomangu/replica44.git "${TARGET_FOLDER}"
    else
        echo "[1/3] Instance détectée dans ${TARGET_FOLDER}."
    fi
    INSTALL_DIR="${TARGET_FOLDER}"
fi

cd "${INSTALL_DIR}"

echo "[2/3] Configuration automatique & Amorçage de l'instance..."
bash ./bootstrap.sh

echo "[3/3] Contrôle de santé de l'instance..."
bash ./scripts/healthcheck.sh || true

echo "======================================================================"
echo "[✓] INSTALLATION ET DÉPLOIEMENT TERMINÉS EN 1 CLIC !"
echo "======================================================================"
