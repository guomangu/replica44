#!/usr/bin/env bash
# ==============================================================================
# Script : install_fedora.sh
# Rôle   : Vérification et installation des prérequis Fedora (Podman/Systemd)
# ==============================================================================

set -euo pipefail

echo "[+] Vérification du socle système Fedora / Linux..."

if ! command -v podman &> /dev/null; then
    echo "[!] Podman non détecté. Installation requise..."
    if command -v dnf &> /dev/null; then
        sudo dnf install -y podman systemd-container
    else
        echo "[X] Gestionnaire dnf non disponible. Veuillez installer podman manuellement."
        exit 1
    fi
fi

if ! command -v rsync &> /dev/null; then
    echo "[!] rsync non détecté. Installation en cours..."
    if command -v dnf &> /dev/null; then
        sudo dnf install -y rsync || true
    fi
fi

# Vérification du support des Quadlets systemd
SYSTEMD_USER_DIR="${HOME}/.config/containers/systemd"
if [ ! -d "${SYSTEMD_USER_DIR}" ]; then
    echo "[+] Création du répertoire Quadlets utilisateur : ${SYSTEMD_USER_DIR}"
    mkdir -p "${SYSTEMD_USER_DIR}"
fi

# Activation du socket Podman utilisateur pour l'IDE Open VS Code
if systemctl --user list-unit-files | grep -q "podman.socket"; then
    echo "[+] Activation du socket Podman utilisateur..."
    systemctl --user enable --now podman.socket 2>/dev/null || true
fi

echo "[✓] Environnement Fedora prêt pour les Quadlets Replica 44."
