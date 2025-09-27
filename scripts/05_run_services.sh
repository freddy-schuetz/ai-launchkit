#!/bin/bash

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# 1. Check for .env file
if [ ! -f ".env" ]; then
  log_error ".env file not found in project root." >&2
  exit 1
fi

# 2. Check for docker-compose.yml file
if [ ! -f "docker-compose.yml" ]; then
  log_error "docker-compose.yml file not found in project root." >&2
  exit 1
fi

# 3. Check for Caddyfile (optional but recommended for reverse proxy)
if [ ! -f "Caddyfile" ]; then
  log_warning "Caddyfile not found in project root. Reverse proxy might not work as expected." >&2
  exit 1
fi

# 4. Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
  log_error "Docker daemon is not running. Please start Docker and try again." >&2
  exit 1
fi

# 5. Check if start_services.py exists and is executable
if [ ! -f "start_services.py" ]; then
  log_error "start_services.py file not found in project root." >&2
  exit 1
fi

if [ ! -x "start_services.py" ]; then
  log_warning "start_services.py is not executable. Making it executable..."
  chmod +x "start_services.py"
fi

# Create media directories with correct permissions BEFORE Docker starts
log_info "Creating media processing directories..."
mkdir -p media temp
# Use SUDO_USER if available (when run with sudo), otherwise current user
if [ -n "$SUDO_USER" ]; then
  chown -R $SUDO_USER:$SUDO_USER media temp
else
  chown -R $(whoami):$(whoami) media temp
fi
chmod 755 media temp
log_info "Media directories created with correct permissions"

# Setup Postal configuration if needed
if [ -f "./scripts/setup_postal.sh" ]; then
  log_info "Checking for Postal setup..."
  bash ./scripts/setup_postal.sh
fi

# Build services that need local compilation
source .env
if [[ "$COMPOSE_PROFILES" == *"tts-chatterbox"* ]]; then
    log_info "Checking Chatterbox Frontend..."
    # Clone the repository if not exists
    if [ ! -d "./chatterbox-frontend/frontend" ]; then
        log_info "Cloning Chatterbox TTS API repository for frontend..."
        git clone https://github.com/travisvn/chatterbox-tts-api.git ./chatterbox-frontend || {
            log_error "Failed to clone Chatterbox repository"
            log_warning "Chatterbox Frontend will not be available"
        }
    fi
    
    # Build the frontend if source exists
    if [ -d "./chatterbox-frontend/frontend" ]; then
        log_info "Building Chatterbox Frontend from source..."
        docker compose -p localai build chatterbox-frontend || {
            log_warning "Failed to build Chatterbox Frontend - API will work but no UI"
        }
    fi
fi

log_info "Launching services using start_services.py..."
# Execute start_services.py
./start_services.py

# Explicitly start services with profiles that need building
if [[ "$COMPOSE_PROFILES" == *"tts-chatterbox"* ]]; then
    log_info "Starting Chatterbox services..."
    docker compose -p localai --profile tts-chatterbox up -d
fi

# Start SSH tunnel after main services are running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"

# Check if SSH tunnel is already running
if docker ps --filter "name=cloudflared-ssh" --filter "status=running" --format "table {{.Names}}" | grep -q "cloudflared-ssh"; then
    log_info "SSH tunnel is already running - skipping start (will be restarted during update if needed)"
else
    log_info "Starting SSH tunnel after main services..."
    bash "$SCRIPT_DIR/ssh_tunnel_manager.sh" start "$PROJECT_ROOT"
fi

exit 0 
