#!/usr/bin/env bash
# ==============================================================================
# Script : find_free_port_block.sh
# Rôle   : Recherche le 1er bloc de 10 ports consécutifs libres dès le port 4000
# Conforme à la Règle 1 (< 100 lignes)
# ==============================================================================

set -euo pipefail

START_PORT=4000
BLOCK_SIZE=10

is_port_in_use() {
    local port="$1"
    if command -v ss &>/dev/null; then
        if ss -tuln | grep -qE ":${port}\b"; then
            return 0
        fi
    fi
    if command -v python3 &>/dev/null; then
        python3 -c "
import socket, sys
port = int(sys.argv[1])
for sock_type in (socket.SOCK_STREAM, socket.SOCK_DGRAM):
    try:
        s = socket.socket(socket.AF_INET, sock_type)
        s.bind(('0.0.0.0', port))
        s.close()
    except Exception:
        sys.exit(0) # Port in use!
sys.exit(1) # Port free
" "${port}" && return 0 || return 1
    fi
    (echo > "/dev/tcp/127.0.0.1/${port}") 2>/dev/null && return 0
    return 1
}

find_free_block() {
    local base_port=$START_PORT
    while true; do
        local block_free=true
        for (( offset=0; offset<BLOCK_SIZE; offset++ )); do
            local current_port=$(( base_port + offset ))
            if is_port_in_use "${current_port}"; then
                block_free=false
                break
            fi
        done

        if [ "${block_free}" = true ]; then
            echo "${base_port}"
            return 0
        fi

        base_port=$(( base_port + BLOCK_SIZE ))
    done
}

find_free_block
