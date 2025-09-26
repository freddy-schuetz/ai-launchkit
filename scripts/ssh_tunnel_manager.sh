#!/bin/bash

# SSH Tunnel Management Script
# Handles starting, stopping, and restarting the isolated SSH tunnel service

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# SSH Tunnel Management Functions
stop_ssh_tunnel() {
    local project_root="$1"
    local ssh_tunnel_dir="$project_root/ssh-tunnel"
    
    if [ -f "$ssh_tunnel_dir/docker-compose.yml" ]; then
        log_info "Stopping SSH tunnel..."
        cd "$ssh_tunnel_dir"
        sudo docker compose -p ssh-tunnel down 2>/dev/null || true
        log_success "SSH tunnel stopped"
    else
        log_info "No SSH tunnel configuration found - skipping stop"
    fi
}

start_ssh_tunnel() {
    local project_root="$1"
    local pull_image="${2:-false}"  # Optional parameter to pull image
    local ssh_tunnel_dir="$project_root/ssh-tunnel"
    local ssh_tunnel_env="$ssh_tunnel_dir/.env"
    
    if [ -f "$ssh_tunnel_dir/docker-compose.yml" ]; then
        # Check if SSH tunnel .env file exists and has token
        if [ ! -f "$ssh_tunnel_env" ]; then
            log_warning "SSH tunnel .env file not found at $ssh_tunnel_env - SSH tunnel will not start"
            return
        fi
        
        # Check if CLOUDFLARE_SSH_TUNNEL_TOKEN is set in ssh-tunnel/.env
        if ! grep -q "^CLOUDFLARE_SSH_TUNNEL_TOKEN=" "$ssh_tunnel_env" || \
           [ -z "$(grep "^CLOUDFLARE_SSH_TUNNEL_TOKEN=" "$ssh_tunnel_env" | cut -d'=' -f2- | sed 's/^\"//' | sed 's/\"$//')" ]; then
            log_warning "CLOUDFLARE_SSH_TUNNEL_TOKEN not set in $ssh_tunnel_env - SSH tunnel will not start"
            return
        fi
        
        cd "$ssh_tunnel_dir"
        
        # Pull image if requested
        if [ "$pull_image" = "true" ]; then
            log_info "Pulling latest SSH tunnel image..."
            sudo docker compose -p ssh-tunnel pull 2>/dev/null || {
                log_warning "Failed to pull SSH tunnel image - continuing with existing image"
            }
        fi
        
        log_info "Starting SSH tunnel..."
        sudo docker compose -p ssh-tunnel up -d 2>/dev/null || {
            log_error "Failed to start SSH tunnel"
            return 1
        }
        log_success "SSH tunnel started"
    else
        log_info "No SSH tunnel configuration found - skipping start"
    fi
}

restart_ssh_tunnel() {
    local project_root="$1"
    local ssh_tunnel_dir="$project_root/ssh-tunnel"
    
    if [ -f "$ssh_tunnel_dir/docker-compose.yml" ]; then
        log_info "Restarting SSH tunnel with latest image..."
        
        # Stop the tunnel
        stop_ssh_tunnel "$project_root"
        
        # Pull latest image
        log_info "Pulling latest cloudflared image..."
        cd "$ssh_tunnel_dir"
        sudo docker compose -p ssh-tunnel pull 2>/dev/null || {
            log_warning "Failed to pull SSH tunnel image - continuing with existing image"
        }
        
        # Brief pause before restart
        sleep 2
        
        # Start with updated image
        start_ssh_tunnel "$project_root"
    else
        log_info "No SSH tunnel configuration found - skipping restart"
    fi
}

status_ssh_tunnel() {
    local project_root="$1"
    local ssh_tunnel_dir="$project_root/ssh-tunnel"
    
    if [ -f "$ssh_tunnel_dir/docker-compose.yml" ]; then
        log_info "SSH tunnel status:"
        cd "$ssh_tunnel_dir"
        sudo docker compose -p ssh-tunnel ps || true
    else
        log_info "No SSH tunnel configuration found"
    fi
}

# Command line interface
case "${1:-}" in
    "start")
        start_ssh_tunnel "${2:-$(pwd)}" "${3:-false}"
        ;;
    "stop")
        stop_ssh_tunnel "${2:-$(pwd)}"
        ;;
    "restart")
        restart_ssh_tunnel "${2:-$(pwd)}"
        ;;
    "status")
        status_ssh_tunnel "${2:-$(pwd)}"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status} [project_root] [pull_image]"
        echo ""
        echo "Commands:"
        echo "  start    - Start SSH tunnel (optionally pull image first)"
        echo "  stop     - Stop SSH tunnel"
        echo "  restart  - Restart SSH tunnel with image pull"
        echo "  status   - Show SSH tunnel status"
        echo ""
        echo "Parameters:"
        echo "  project_root - Path to project root (default: current directory)"
        echo "  pull_image   - true/false to pull image before start (default: false)"
        echo ""
        echo "Examples:"
        echo "  $0 start"
        echo "  $0 start /path/to/project true"
        echo "  $0 restart"
        echo "  $0 status"
        exit 1
        ;;
esac