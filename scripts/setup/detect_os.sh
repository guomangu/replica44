#!/usr/bin/env bash
# ==============================================================================
# Script : detect_os.sh
# Rôle   : Détection de l'OS hôte pour l'agnosticisme matériel (Règle 2)
# ==============================================================================

set -euo pipefail

detect_os() {
    local os_type="unknown"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "${ID:-}" == "fedora" ]] || [[ "${ID_LIKE:-}" =~ "fedora" ]]; then
            os_type="fedora"
        elif grep -qi microsoft /proc/version 2>/dev/null; then
            os_type="wsl"
        else
            os_type="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macos"
    fi

    echo "$os_type"
}

OS_DETECTED=$(detect_os)
echo "[i] Système d'exploitation détecté : ${OS_DETECTED}"
export REPLICA44_OS="${OS_DETECTED}"
