#!/bin/bash

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Set the compose command explicitly to use docker compose subcommand

# Navigate to the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Project root directory (one level up from scripts)
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"
# Path to the apply_update.sh script
APPLY_UPDATE_SCRIPT="$SCRIPT_DIR/apply_update.sh"

# Check if apply update script exists
if [ ! -f "$APPLY_UPDATE_SCRIPT" ]; then
    log_error "Crucial update script $APPLY_UPDATE_SCRIPT not found. Cannot proceed."
    exit 1
fi


log_info "Starting update process..."

# Pull the latest repository changes
log_info "Pulling latest repository changes..."
# Check if git is installed
if ! command -v git &> /dev/null; then
    log_warning "'git' command not found. Skipping repository update."
    # Decide if we should proceed without git pull or exit. Exiting is safer.
    log_error "Cannot proceed with update without git. Please install git."
    exit 1
    # Or, if allowing update without pull:
    # log_warning "Proceeding without pulling latest changes..."
else
    # Change to project root for git pull
    cd "$PROJECT_ROOT" || { log_error "Failed to change directory to $PROJECT_ROOT"; exit 1; }
    git reset --hard HEAD || { log_warning "Failed to reset repository. Continuing update with potentially unreset local changes..."; }
    git pull || { log_warning "Failed to pull latest repository changes. Continuing update with potentially old version of apply_update.sh..."; }
    # Change back to script dir or ensure apply_update.sh uses absolute paths or cd's itself
    # (apply_update.sh already handles cd to PROJECT_ROOT, so we're good)
fi

# Update Ubuntu packages before running apply_update
log_info "Updating system packages..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get upgrade -y
    log_info "System packages updated successfully."
else
    log_warning "'apt-get' not found. Skipping system package update. This is normal on non-debian systems."
fi

# Build Cal.com if selected (needed for updates)
log_info "Checking if Cal.com needs to be built..."
if grep -q "calcom" "$PROJECT_ROOT/.env" 2>/dev/null || [[ "$COMPOSE_PROFILES" == *"calcom"* ]]; then
    if [ -f "$SCRIPT_DIR/build_calcom.sh" ]; then
        log_info "Cal.com detected - preparing build..."
        bash "$SCRIPT_DIR/build_calcom.sh" || { log_error "Cal.com build preparation failed"; exit 1; }
        log_success "Cal.com build preparation complete!"
    else
        log_warning "Cal.com selected but build script not found"
    fi
else
    log_info "Cal.com not selected, skipping build"
fi

# Execute the rest of the update process using the (potentially updated) apply_update.sh
bash "$APPLY_UPDATE_SCRIPT"

# Workaround: Ensure Supabase DB starts if Supabase was selected
if grep -q "supabase" "$PROJECT_ROOT/.env" 2>/dev/null; then
    log_info "Ensuring Supabase database container is running..."
    cd "$PROJECT_ROOT" || true
    sudo docker compose -p localai -f supabase/docker/docker-compose.yml up -d db 2>/dev/null || true
fi

# Workaround: Ensure LibreTranslate starts properly if selected
if grep -q "libretranslate" "$PROJECT_ROOT/.env" 2>/dev/null || docker ps -a | grep -q libretranslate; then
    log_info "Ensuring LibreTranslate container is running properly..."
    sudo docker compose -p localai stop libretranslate 2>/dev/null || true
    sudo docker compose -p localai rm -f libretranslate 2>/dev/null || true
    sudo docker compose -p localai --profile libretranslate up -d libretranslate 2>/dev/null || true
fi

# The final success message will now come from apply_update.sh
log_info "Update script finished." # Changed final message

# Check if SSH tunnel is configured and ask user about restart
SSH_TUNNEL_CONFIG="$PROJECT_ROOT/ssh-tunnel/docker-compose.yml"
if [ -f "$SSH_TUNNEL_CONFIG" ]; then
    echo
    echo "======================================================================"
    echo "SSH Tunnel Restart Required"
    echo "======================================================================"
    echo
    log_warning "The update process requires restarting the SSH tunnel to use the latest image."
    log_warning "⚠️  WARNING: If you are connected through the SSH tunnel, this will"
    log_warning "   temporarily disconnect your session during the restart process."
    echo
    echo "The tunnel restart will:"
    echo "  • Pull the latest cloudflared image"
    echo "  • Restart the tunnel service"
    echo "  • Take approximately 10-30 seconds"
    echo
    read -p "Do you want to restart the SSH tunnel now? (y/N): " -r restart_tunnel
    echo
    
    case "$restart_tunnel" in
        [Yy]|[Yy][Ee][Ss])
            log_info "Restarting SSH tunnel in background process..."
            echo "Starting SSH tunnel restart in 5 seconds..."
            echo "If you lose connection, wait 30 seconds and reconnect."
            echo
            sleep 5
            # Use nohup and disown to ensure process survives even if terminal is killed
            nohup bash "$SCRIPT_DIR/ssh_tunnel_manager.sh" restart "$PROJECT_ROOT" > /tmp/ssh_tunnel_restart.log 2>&1 &
            disown
            log_success "SSH tunnel restart initiated in background."
            echo "Check restart status: tail -f /tmp/ssh_tunnel_restart.log"
            ;;
        *)
            log_info "SSH tunnel restart skipped."
            log_warning "To restart manually later, run:"
            log_warning "  bash $SCRIPT_DIR/ssh_tunnel_manager.sh restart $PROJECT_ROOT"
            ;;
    esac
fi

exit 0
