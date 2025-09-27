# SSH Tunnel Configuration

This folder contains the isolated SSH tunnel service that provides secure SSH access via Cloudflare tunnel.

## How it works

- The SSH tunnel runs separately from the main application stack
- During updates, the main services restart while SSH tunnel keeps running
- Only at the very end of an update, the SSH tunnel gets briefly restarted
- This prevents SSH connection drops during the main update process

## Configuration

The SSH tunnel token is configured during the initial wizard setup and stored in `ssh-tunnel/.env`.

## Management

The SSH tunnel is automatically managed by:
- `update.sh` - Restarts tunnel at the end of updates
- `05_run_services.sh` - Starts tunnel after main services
- `utils.sh` functions: `start_ssh_tunnel()`, `stop_ssh_tunnel()`, `restart_ssh_tunnel()`