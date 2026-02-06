#!/bin/bash
# Counter-Strike: Source Soccer Server Entrypoint
# Handles first-run initialization, configuration generation, and server startup
# Extends base css-server entrypoint with soccer-specific features

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo -e "${CYAN}=== $1 ===${NC}"
}

# Handle update request
if [ "$1" == "update" ]; then
    log_info "Updating Counter-Strike: Source..."
    /home/steam/steamcmd/steamcmd.sh \
        +force_install_dir /home/steam/css \
        +login anonymous \
        +app_update 232330 validate \
        +quit
    log_info "Update complete!"
    exit 0
fi

# Handle shell request
if [ "$1" == "bash" ] || [ "$1" == "sh" ]; then
    exec /bin/bash
fi

# ============================================
# FIRST-RUN INITIALIZATION
# ============================================
# When volumes are mounted but empty, copy defaults from the image backup
# IMPORTANT: This only populates EMPTY volumes - existing files are NEVER overwritten

initialize_volumes() {
    log_section "Checking Volumes"

    local BACKUP_DIR="/home/steam/css-defaults"
    local CSTRIKE_DIR="/home/steam/css/cstrike"

    # CFG directory - only if empty
    if [ -d "$CSTRIKE_DIR/cfg" ] && [ -z "$(ls -A $CSTRIKE_DIR/cfg 2>/dev/null)" ]; then
        log_info "Initializing cfg/ with defaults..."
        cp -r "$BACKUP_DIR/cfg/"* "$CSTRIKE_DIR/cfg/" 2>/dev/null || true
    else
        log_info "cfg/ already has content - preserving existing files"
    fi

    # ADDONS directory - only if empty
    if [ -d "$CSTRIKE_DIR/addons" ] && [ -z "$(ls -A $CSTRIKE_DIR/addons 2>/dev/null)" ]; then
        log_info "Initializing addons/ with defaults (MetaMod + SourceMod + Soccer Mod)..."
        cp -r "$BACKUP_DIR/addons/"* "$CSTRIKE_DIR/addons/" 2>/dev/null || true
    else
        log_info "addons/ already has content - preserving existing files"
    fi

    # If addons exists but sourcemod subfolder is empty (granular mount)
    if [ -d "$CSTRIKE_DIR/addons/sourcemod" ]; then
        if [ -d "$CSTRIKE_DIR/addons/sourcemod/plugins" ] && [ -z "$(ls -A $CSTRIKE_DIR/addons/sourcemod/plugins 2>/dev/null)" ]; then
            log_info "Initializing sourcemod/plugins/ with defaults..."
            cp -r "$BACKUP_DIR/addons/sourcemod/plugins/"* "$CSTRIKE_DIR/addons/sourcemod/plugins/" 2>/dev/null || true
        fi

        if [ -d "$CSTRIKE_DIR/addons/sourcemod/configs" ] && [ -z "$(ls -A $CSTRIKE_DIR/addons/sourcemod/configs 2>/dev/null)" ]; then
            log_info "Initializing sourcemod/configs/ with defaults..."
            cp -r "$BACKUP_DIR/addons/sourcemod/configs/"* "$CSTRIKE_DIR/addons/sourcemod/configs/" 2>/dev/null || true
        fi

        if [ -d "$CSTRIKE_DIR/addons/sourcemod/data" ] && [ -z "$(ls -A $CSTRIKE_DIR/addons/sourcemod/data 2>/dev/null)" ]; then
            log_info "Initializing sourcemod/data/ with defaults..."
            cp -r "$BACKUP_DIR/addons/sourcemod/data/"* "$CSTRIKE_DIR/addons/sourcemod/data/" 2>/dev/null || true
        fi

        if [ -d "$CSTRIKE_DIR/addons/sourcemod/translations" ] && [ -z "$(ls -A $CSTRIKE_DIR/addons/sourcemod/translations 2>/dev/null)" ]; then
            log_info "Initializing sourcemod/translations/ with defaults..."
            cp -r "$BACKUP_DIR/addons/sourcemod/translations/"* "$CSTRIKE_DIR/addons/sourcemod/translations/" 2>/dev/null || true
        fi
    fi

    # Ensure metamod.vdf exists (critical for plugin loading)
    if [ ! -f "$CSTRIKE_DIR/addons/metamod.vdf" ]; then
        log_info "Creating metamod.vdf loader..."
        mkdir -p "$CSTRIKE_DIR/addons"
        echo '"Plugin"' > "$CSTRIKE_DIR/addons/metamod.vdf"
        echo '{' >> "$CSTRIKE_DIR/addons/metamod.vdf"
        echo '    "file" "../cstrike/addons/metamod/bin/linux64/server"' >> "$CSTRIKE_DIR/addons/metamod.vdf"
        echo '}' >> "$CSTRIKE_DIR/addons/metamod.vdf"
    fi

    # Initialize maps folder - only if empty
    if [ -d "$CSTRIKE_DIR/maps" ] && [ -z "$(ls -A $CSTRIKE_DIR/maps 2>/dev/null)" ]; then
        log_info "Initializing maps/ with defaults..."
        cp -r "$BACKUP_DIR/maps/"* "$CSTRIKE_DIR/maps/" 2>/dev/null || true
    else
        log_info "maps/ already has content - preserving existing files"
    fi

    # Create empty directories if they don't exist (for mounts)
    mkdir -p "$CSTRIKE_DIR/maps" 2>/dev/null || true
    mkdir -p "$CSTRIKE_DIR/sound" 2>/dev/null || true
    mkdir -p "$CSTRIKE_DIR/materials" 2>/dev/null || true
    mkdir -p "$CSTRIKE_DIR/models" 2>/dev/null || true
    mkdir -p "$CSTRIKE_DIR/particles" 2>/dev/null || true
    mkdir -p "$CSTRIKE_DIR/download" 2>/dev/null || true
    mkdir -p "$CSTRIKE_DIR/logs" 2>/dev/null || true
    mkdir -p "$CSTRIKE_DIR/addons/sourcemod/logs" 2>/dev/null || true

    log_info "Volume initialization complete"
}

# Generate dynamic configuration from environment variables
generate_env_config() {
    log_section "Generating Configuration"

    local cfg_file="/home/steam/css/cstrike/cfg/env_settings.cfg"

    cat > "$cfg_file" << EOF
// ============================================
// AUTO-GENERATED FROM ENVIRONMENT VARIABLES
// DO NOT EDIT - Changes will be overwritten on restart
// ============================================
// Generated at: $(date)
// Only explicitly set env vars are included here.
// Base settings come from server.cfg

EOF

    # Server Identity (always set hostname)
    echo "// === Server Identity ===" >> "$cfg_file"
    echo "hostname \"${CSS_HOSTNAME:-CSS Soccer Server}\"" >> "$cfg_file"
    [ -n "$CSS_CONTACT" ] && echo "sv_contact \"$CSS_CONTACT\"" >> "$cfg_file"
    [ -n "$CSS_REGION" ] && echo "sv_region $CSS_REGION" >> "$cfg_file"

    # Fast Download (critical for custom content like skins)
    echo "" >> "$cfg_file"
    echo "// === Fast Download ===" >> "$cfg_file"
    [ -n "$CSS_DOWNLOADURL" ] && echo "sv_downloadurl \"$CSS_DOWNLOADURL\"" >> "$cfg_file"
    [ -n "$CSS_MAXFILESIZE" ] && echo "net_maxfilesize $CSS_MAXFILESIZE" >> "$cfg_file"

    log_info "Generated env_settings.cfg"
}

# Create my-server.cfg if it doesn't exist
ensure_custom_config() {
    local cfg_file="/home/steam/css/cstrike/cfg/my-server.cfg"
    if [ ! -f "$cfg_file" ]; then
        cat > "$cfg_file" << 'EOF'
// ============================================
// Custom Server Configuration
// ============================================
// Add your custom settings here.
// This file persists across container restarts.
//
// Example:
// mp_autoteambalance 1
// sv_alltalk 1
EOF
        log_info "Created my-server.cfg template"
    fi
}

# Ensure ban files exist
ensure_ban_files() {
    touch /home/steam/css/cstrike/cfg/banned_user.cfg 2>/dev/null || true
    touch /home/steam/css/cstrike/cfg/banned_ip.cfg 2>/dev/null || true
}

# Verify installation
verify_installation() {
    log_section "Verifying Installation"

    local errors=0

    if [ ! -f "/home/steam/css/srcds_run" ]; then
        log_error "srcds_run not found!"
        errors=$((errors + 1))
    else
        log_info "srcds_run: OK"
    fi

    if [ ! -d "/home/steam/css/cstrike/addons/metamod" ]; then
        log_warn "MetaMod not found - plugins may not work"
    else
        log_info "MetaMod: OK"
    fi

    if [ ! -d "/home/steam/css/cstrike/addons/sourcemod" ]; then
        log_warn "SourceMod not found - admin features may not work"
    else
        log_info "SourceMod: OK"
    fi

    # Check for Soccer Mod
    if [ -f "/home/steam/css/cstrike/addons/sourcemod/plugins/soccer_mod.smx" ]; then
        log_info "Soccer Mod: OK"
    else
        log_warn "Soccer Mod plugin not found!"
    fi

    if [ $errors -gt 0 ]; then
        log_error "Installation verification failed!"
        exit 1
    fi
}

# Print startup banner
print_banner() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         Counter-Strike: Source Soccer Server              ║${NC}"
    echo -e "${CYAN}║              with Soccer Mod (SoMoE-19)                    ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "  Hostname:    ${CSS_HOSTNAME:-CSS Soccer Server}"
    echo "  Map:         ${CSS_MAP:-soccer_psl_breezeway_fix}"
    echo "  Max Players: ${CSS_MAXPLAYERS:-14}"
    echo "  Tickrate:    ${CSS_TICKRATE:-100}"
    echo "  Port:        ${CSS_PORT:-27015}"
    echo ""
    if [ -n "$STEAM_GSLT" ]; then
        echo -e "  GSLT:        ${GREEN}Configured (public server)${NC}"
    else
        echo -e "  GSLT:        ${YELLOW}Not set (LAN mode only)${NC}"
    fi
    echo ""
}

# Main startup sequence
main() {
    print_banner
    initialize_volumes
    verify_installation
    ensure_ban_files
    ensure_custom_config
    generate_env_config

    log_section "Starting Server"

    # Build server arguments
    SERVER_ARGS=""

    # Add GSLT if provided (required for public servers)
    if [ -n "$STEAM_GSLT" ]; then
        SERVER_ARGS="$SERVER_ARGS +sv_setsteamaccount $STEAM_GSLT"
        log_info "Steam Game Server Login Token configured"
    else
        log_warn "No STEAM_GSLT set - server will run in LAN mode only"
        SERVER_ARGS="$SERVER_ARGS +sv_lan 1"
    fi

    if [ -n "$CSS_PASSWORD" ]; then
        log_info "Server password is set"
    fi

    if [ -z "$RCON_PASSWORD" ]; then
        log_warn "No RCON_PASSWORD set - RCON will be disabled"
    else
        log_info "RCON password is set"
    fi

    echo ""
    log_info "Launching srcds_run_64 (64-bit)..."
    echo ""

    # Change to server directory and start
    cd /home/steam/css

    exec ./srcds_run_64 \
        -game cstrike \
        -port "${CSS_PORT:-27015}" \
        +map "${CSS_MAP:-soccer_psl_breezeway_fix}" \
        +maxplayers "${CSS_MAXPLAYERS:-14}" \
        -tickrate "${CSS_TICKRATE:-100}" \
        +sv_password "${CSS_PASSWORD:-}" \
        +rcon_password "${RCON_PASSWORD:-}" \
        +exec server.cfg \
        +exec env_settings.cfg \
        +exec my-server.cfg \
        -norestart \
        $SERVER_ARGS \
        "$@"
}

# Run main function
main "$@"
