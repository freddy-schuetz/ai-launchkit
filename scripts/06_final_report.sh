#!/bin/bash

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Get the directory where the script resides
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"
ENV_FILE="$PROJECT_ROOT/.env"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    log_error "The .env file ('$ENV_FILE') was not found."
    exit 1
fi

# Load environment variables from .env file
# Use set -a to export all variables read from the file
set -a
source "$ENV_FILE"
set +a

# Function to check if a profile is active
is_profile_active() {
    local profile_to_check="$1"
    # COMPOSE_PROFILES is sourced from .env and will be available here
    if [ -z "$COMPOSE_PROFILES" ]; then
        return 1 # Not active if COMPOSE_PROFILES is empty or not set
    fi
    # Check if the profile_to_check is in the comma-separated list
    # Adding commas at the beginning and end of both strings handles edge cases
    # (e.g., single profile, profile being a substring of another)
    if [[ ",$COMPOSE_PROFILES," == *",$profile_to_check,"* ]]; then
        return 0 # Active
    else
        return 1 # Not active
    fi
}

# --- Service Access Credentials ---

# Display credentials, checking if variables exist
echo
log_info "Service Access Credentials. Save this information securely!"
# Display credentials, checking if variables exist

if is_profile_active "n8n"; then
  echo
  echo "================================= n8n ================================="
  echo
  echo "Host: ${N8N_HOSTNAME:-<hostname_not_set>}"
fi

if is_profile_active "open-webui"; then
  echo
  echo "================================= WebUI ==============================="
  echo
  echo "Host: ${WEBUI_HOSTNAME:-<hostname_not_set>}"
fi

if is_profile_active "flowise"; then
  echo
  echo "================================= Flowise ============================="
  echo
  echo "Host: ${FLOWISE_HOSTNAME:-<hostname_not_set>}"
  echo "User: ${FLOWISE_USERNAME:-<not_set_in_env>}"
  echo "Password: ${FLOWISE_PASSWORD:-<not_set_in_env>}"
fi

if is_profile_active "bolt"; then
  echo
  echo "================================= Bolt.diy ==========================="
  echo
  echo "Host: ${BOLT_HOSTNAME:-<hostname_not_set>}"
  echo "User: ${BOLT_USERNAME:-<not_set_in_env>}"
  echo "Password: ${BOLT_PASSWORD:-<not_set_in_env>}"
  echo "URL: https://${BOLT_HOSTNAME:-<hostname_not_set>}"
  echo "Internal URL: http://bolt:5173"
  echo "Description: AI-powered web development in the browser"
  echo "Documentation: https://github.com/stackblitz-labs/bolt.diy"
  echo
fi

if is_profile_active "openui"; then
  echo
  echo "================================= OpenUI ==============================="
  echo
  echo "⚠️  EXPERIMENTAL: Output quality varies significantly by model"
  echo
  echo "Host: ${OPENUI_HOSTNAME:-<hostname_not_set>}"
  echo "Description: AI-powered UI component generator"
  echo "Best Models: Claude 4 Sonnet, GPT-4, Groq (for speed)"
  echo "Note: Can use Ollama but results may be inconsistent"
  echo "Documentation: https://github.com/wandb/openui"
fi

if is_profile_active "dify"; then
  echo
  echo "================================= Dify ================================="
  echo
  echo "Host: ${DIFY_HOSTNAME:-<hostname_not_set>}"
  echo "Description: AI Application Development Platform with LLMOps"
  echo
  echo "API Access:"
  echo "  - Web Interface: https://${DIFY_HOSTNAME:-<hostname_not_set>}"
  echo "  - API Endpoint: https://${DIFY_HOSTNAME:-<hostname_not_set>}/v1"
  echo "  - Internal API: http://dify-api:5001"
fi

if is_profile_active "supabase"; then
  echo
  echo "================================= Supabase ============================"
  echo
  echo "External Host (via Caddy): ${SUPABASE_HOSTNAME:-<hostname_not_set>}"
  echo "Studio User: ${DASHBOARD_USERNAME:-<not_set_in_env>}"
  echo "Studio Password: ${DASHBOARD_PASSWORD:-<not_set_in_env>}"
  echo
  echo "Internal API Gateway: http://kong:8000"
  echo "Service Role Secret: ${SERVICE_ROLE_KEY:-<not_set_in_env>}"
fi

if is_profile_active "langfuse"; then
  echo
  echo "================================= Langfuse ============================"
  echo
  echo "Host: ${LANGFUSE_HOSTNAME:-<hostname_not_set>}"
  echo "User: ${LANGFUSE_INIT_USER_EMAIL:-<not_set_in_env>}"
  echo "Password: ${LANGFUSE_INIT_USER_PASSWORD:-<not_set_in_env>}"
fi

if is_profile_active "monitoring"; then
  echo
  echo "================================= Grafana ============================="
  echo
  echo "Host: ${GRAFANA_HOSTNAME:-<hostname_not_set>}"
  echo "User: admin"
  echo "Password: ${GRAFANA_ADMIN_PASSWORD:-<not_set_in_env>}"
  echo
  echo "================================= Prometheus =========================="
  echo
  echo "Host: ${PROMETHEUS_HOSTNAME:-<hostname_not_set>}"
  echo "User: ${PROMETHEUS_USERNAME:-<not_set_in_env>}"
  echo "Password: ${PROMETHEUS_PASSWORD:-<not_set_in_env>}"
fi

if is_profile_active "searxng"; then
  echo
  echo "================================= Searxng ============================="
  echo
  echo "Host: ${SEARXNG_HOSTNAME:-<hostname_not_set>}"
  echo "User: ${SEARXNG_USERNAME:-<not_set_in_env>}"
  echo "Password: ${SEARXNG_PASSWORD:-<not_set_in_env>}"
fi

if is_profile_active "perplexica"; then
  echo
  echo "================================= Perplexica =========================="
  echo
  echo "Host: ${PERPLEXICA_HOSTNAME:-<hostname_not_set>}"
  echo "User: ${PERPLEXICA_USERNAME:-<not_set_in_env>}"
  echo "Password: ${PERPLEXICA_PASSWORD:-<not_set_in_env>}"
  echo
  echo "Access:"
  echo "  External (HTTPS): https://${PERPLEXICA_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal API: http://perplexica-backend:3001"
  echo
  echo "Features:"
  echo "  - 6 Focus Modes (Academic, YouTube, Reddit, Writing, etc.)"
  echo "  - Uses your SearXNG instance for web search"
  echo "  - Integrates with Ollama for local LLMs"
  echo "  - Can also use OpenAI/Anthropic/Groq if configured"
  echo
  echo "n8n Integration:"
  echo "  API Endpoint: http://perplexica-backend:3001/api/search"
  echo "  Method: POST"
  echo "  Body: {\"query\": \"your search\", \"mode\": \"all\"}"
  echo
  echo "Documentation: https://github.com/ItzCrazyKns/Perplexica"
  echo
  echo "Note: First start takes ~5-10 minutes to build the containers"
fi

if is_profile_active "portainer"; then
  echo
  echo "================================= Portainer ==========================="
  echo
  echo "Host: ${PORTAINER_HOSTNAME:-<hostname_not_set>}"
  echo "(Note: On first login, Portainer will prompt to set up an admin user.)"
fi

if is_profile_active "postiz"; then
  echo
  echo "================================= Postiz =============================="
  echo
  echo "Host: ${POSTIZ_HOSTNAME:-<hostname_not_set>}"
  echo "Internal Access (e.g., from n8n): http://postiz:5000"
fi

if is_profile_active "odoo"; then
  echo
  echo "================================= Odoo 18 ERP/CRM ====================="
  echo
  echo "Host: ${ODOO_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access URLs:"
  echo "  Main: https://${ODOO_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal: http://odoo:8069"
  echo
  echo "Database Setup (first login):"
  echo "  Master Password: ${ODOO_MASTER_PASSWORD:-<check .env file>}"
  echo "  Database Name: odoo"
  echo "  Admin Email: Use your email"
  echo "  Admin Password: Create a strong password"
  echo
  echo "n8n Integration:"
  echo "  Use native Odoo node in n8n"
  echo "  Internal URL: http://odoo:8069"
  echo "  API Endpoint: /web/session/authenticate"
  echo
  echo "AI Features (Odoo 18):"
  echo "  - AI-powered lead scoring"
  echo "  - Content generation for marketing"
  echo "  - Sales forecasting with ML"
  echo "  - Automated expense processing"
  echo
  echo "Resources:"
  echo "  RAM Usage: ~2-4GB (2 workers)"
  echo "  Disk: ~5-10GB initial"
  echo
  echo "Documentation: https://www.odoo.com/documentation/18.0/"
fi

if is_profile_active "plane"; then
  echo
  echo "================================= Plane ==============================="
  echo
  echo "Host: ${PLANE_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access:"
  echo "  External: https://${PLANE_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal API: http://plane-api:8000"
  echo
  echo "Setup:"
  echo "  1. First user to register becomes admin"
  echo "  2. Create workspace"
  echo "  3. Invite team members"
  echo
  echo "n8n Integration:"
  echo "  API Endpoint: http://plane-api:8000/api"
  echo "  Authentication: API Token (generate in user settings)"
  echo
  echo "Documentation: https://docs.plane.so"
fi

if is_profile_active "baserow"; then
  echo
  echo "================================= Baserow ============================"
  echo
  echo "Host: ${BASEROW_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access:"
  echo "  External: https://${BASEROW_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal API: http://baserow:80"
  echo
  echo "Setup:"
  echo "  First user to register becomes admin"
  echo "  Create workspaces and databases after login"
  echo
  echo "n8n Integration:"
  echo "  External URL: https://${BASEROW_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal URL: http://baserow:80 (add Host header: ${BASEROW_HOSTNAME})"
  echo "  Or use external URL for simpler setup"
  echo "  Authentication: Username/Password or API Token"
  echo "  Generate API token in user settings after setup"
  echo
  echo "Documentation: https://baserow.io/docs"
fi

if is_profile_active "ragapp"; then
  echo
  echo "================================= RAGApp =============================="
  echo
  echo "Host: ${RAGAPP_HOSTNAME:-<hostname_not_set>}"
  echo "Internal Access (e.g., from n8n): http://ragapp:8000"
  echo "User: ${RAGAPP_USERNAME:-<not_set_in_env>}"
  echo "Password: ${RAGAPP_PASSWORD:-<not_set_in_env>}"
  echo "Admin: https://${RAGAPP_HOSTNAME:-<hostname_not_set>}/admin"
  echo "API Docs: https://${RAGAPP_HOSTNAME:-<hostname_not_set>}/docs"
fi

if is_profile_active "comfyui"; then
  echo
  echo "================================= ComfyUI ============================="
  echo
  echo "Host: ${COMFYUI_HOSTNAME:-<hostname_not_set>}"
  echo "User: ${COMFYUI_USERNAME:-<not_set_in_env>}"
  echo "Password: ${COMFYUI_PASSWORD:-<not_set_in_env>}"
fi

if is_profile_active "speech"; then
  echo
  echo "================================= Speech Stack ========================="
  echo
  echo "=== Whisper (Speech-to-Text) ==="
  echo "Host: ${WHISPER_HOSTNAME:-<hostname_not_set>}"
  echo "API Endpoint: https://${WHISPER_HOSTNAME:-<hostname_not_set>}/v1/audio/transcriptions"
  echo "Auth User: ${WHISPER_AUTH_USER:-<not_set_in_env>}"
  echo "Model: ${WHISPER_MODEL:-Systran/faster-distil-whisper-large-v3}"
  echo "Internal Access (no auth): http://faster-whisper:8000"
  echo
  echo "=== OpenedAI-Speech (Text-to-Speech) ==="
  echo "Host: ${TTS_HOSTNAME:-<hostname_not_set>}"
  echo "API Endpoint: https://${TTS_HOSTNAME:-<hostname_not_set>}/v1/audio/speech"
  echo "Auth User: ${TTS_AUTH_USER:-<not_set_in_env>}"
  echo "Internal Access (no auth): http://openedai-speech:8000/v1/audio/speech"
  echo
  echo "Note: External access requires Basic Auth. Internal access from n8n is auth-free."
  echo "Note: Services are CPU-optimized for VPS"
fi

if is_profile_active "libretranslate"; then
  echo
  echo "================================= LibreTranslate ==========================="
  echo
  echo "Host: ${LIBRETRANSLATE_HOSTNAME:-<hostname_not_set>}"
  echo "User: ${LIBRETRANSLATE_USERNAME:-<not_set_in_env>}"
  echo "Password: ${LIBRETRANSLATE_PASSWORD:-<not_set_in_env>}"
  echo "API (external via Caddy): https://${LIBRETRANSLATE_HOSTNAME:-<hostname_not_set>}"
  echo "API (internal): http://libretranslate:5000"
  echo ""
  echo "API Endpoints:"
  echo "  - Translate: POST /translate"
  echo "  - Detect Language: POST /detect"
  echo "  - Available Languages: GET /languages"
  echo ""
  echo "Example n8n usage:"
  echo "  URL: http://libretranslate:5000/translate"
  echo "  Method: POST"
  echo "  Body: {\"q\":\"Hello\",\"source\":\"en\",\"target\":\"de\"}"
  echo ""
  echo "Docs: https://github.com/LibreTranslate/LibreTranslate"
fi

if is_profile_active "qdrant"; then
  echo
  echo "================================= Qdrant =============================="
  echo
  echo "Host: https://${QDRANT_HOSTNAME:-<hostname_not_set>}"
  echo "API Key: ${QDRANT_API_KEY:-<not_set_in_env>}"
  echo "Internal REST API Access (e.g., from backend): http://qdrant:6333"
fi

if is_profile_active "crawl4ai"; then
  echo
  echo "================================= Crawl4AI ============================"
  echo
  echo "Internal Access (e.g., from n8n): http://crawl4ai:11235"
  echo "(Note: Not exposed externally via Caddy by default)"
fi

if is_profile_active "gotenberg"; then
  echo
  echo "================================= Gotenberg ============================"
  echo
  echo "Internal Access (e.g., from n8n): http://gotenberg:3000"
  echo "API Documentation: https://gotenberg.dev/docs"
  echo
  echo "Common API Endpoints:"
  echo "  HTML to PDF: POST /forms/chromium/convert/html"
  echo "  URL to PDF: POST /forms/chromium/convert/url"
  echo "  Markdown to PDF: POST /forms/chromium/convert/markdown"
  echo "  Office to PDF: POST /forms/libreoffice/convert"
fi

if is_profile_active "python-runner"; then
  echo
  echo "================================= Python Runner ========================"
  echo
  echo "Internal Container DNS: python-runner"
  echo "Mounted Code Directory: ./python-runner (host) -> /app (container)"
  echo "Entry File: /app/main.py"
  echo "(Note: Internal-only service with no exposed ports; view output via logs)"
  echo "Logs: docker compose -p localai logs -f python-runner"
fi

if is_profile_active "n8n" || is_profile_active "langfuse"; then
  echo
  echo "================================= Redis (Valkey) ======================"
  echo
  echo "Internal Host: ${REDIS_HOST:-redis}"
  echo "Internal Port: ${REDIS_PORT:-6379}"
  echo "Password: ${REDIS_AUTH:-LOCALONLYREDIS} (Note: Default if not set in .env)"
  echo "(Note: Primarily for internal service communication, not exposed externally by default)"
fi

if is_profile_active "letta"; then
  echo
  echo "================================= Letta ================================"
  echo
  echo "Host: ${LETTA_HOSTNAME:-<hostname_not_set>}"
  echo "Authorization: Bearer ${LETTA_SERVER_PASSWORD}"
fi

if is_profile_active "cpu" || is_profile_active "gpu-nvidia" || is_profile_active "gpu-amd"; then
  echo
  echo "================================= Ollama =============================="
  echo
  echo "Internal Access (e.g., from n8n, Open WebUI): http://ollama:11434"
  echo "(Note: Ollama runs with the selected profile: cpu, gpu-nvidia, or gpu-amd)"
fi

if is_profile_active "weaviate"; then
  echo
  echo "================================= Weaviate ============================"
  echo
  echo "Host: ${WEAVIATE_HOSTNAME:-<hostname_not_set>}"
  echo "Admin User (for Weaviate RBAC): ${WEAVIATE_USERNAME:-<not_set_in_env>}"
  echo "Weaviate API Key: ${WEAVIATE_API_KEY:-<not_set_in_env>}"
fi

if is_profile_active "lightrag"; then
  echo
  echo "================================= LightRAG ==========================="
  echo
  echo "Host: ${LIGHTRAG_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Internal API Auth:"
  echo "  Accounts: ${LIGHTRAG_AUTH_ACCOUNTS:-<not_set_in_env>}"
  echo "  Token Expiry: ${LIGHTRAG_TOKEN_EXPIRE:-24} hours"
  echo
  echo "Access:"
  echo "  External (HTTPS): https://${LIGHTRAG_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal (Docker): http://lightrag:9621"
  echo
  echo "n8n Integration:"
  echo "  Use HTTP Request node with URL: http://lightrag:9621/api/query"
  echo "  Query modes: /local, /global, /hybrid, /naive"
  echo
  echo "Open WebUI Integration:"
  echo "  Add as Ollama model type with endpoint: http://lightrag:9621"
  echo "  Model name will appear as: lightrag:latest"
  echo
  echo "Storage Backends:"
  echo "  Default: In-memory (NetworkX + nano-vectordb)"
  echo "  Optional: PostgreSQL, Neo4j, MongoDB, Redis"
  echo
  echo "Documentation: https://github.com/HKUDS/LightRAG"
fi

if is_profile_active "neo4j"; then
  echo
  echo "================================= Neo4j =================================="
  echo
  echo "Web UI Host: https://${NEO4J_HOSTNAME:-<hostname_not_set>}"
  echo "Bolt Port (for drivers): 7687 (e.g., neo4j://\\${NEO4J_HOSTNAME:-<hostname_not_set>}:7687)"
  echo "User (for Web UI & API): ${NEO4J_AUTH_USERNAME:-<not_set_in_env>}"
  echo "Password (for Web UI & API): ${NEO4J_AUTH_PASSWORD:-<not_set_in_env>}"
  echo
  echo "HTTP API Access (e.g., for N8N):"
  echo "  Authentication: Basic (use User/Password above)"
  echo "  Cypher API Endpoint (POST): https://\\${NEO4J_HOSTNAME:-<hostname_not_set>}/db/neo4j/tx/commit"
  echo "  Authorization Header Value (for 'Authorization: Basic <value>'): \$(echo -n \"${NEO4J_AUTH_USERNAME:-neo4j}:${NEO4J_AUTH_PASSWORD}\" | base64)"
fi

# Standalone PostgreSQL (used by n8n, Langfuse, etc.)
# Check if n8n or langfuse is active, as they use this PostgreSQL instance.
# The Supabase section already details its own internal Postgres.
if is_profile_active "n8n" || is_profile_active "langfuse"; then
  # Check if Supabase is NOT active, to avoid confusion with Supabase's Postgres if both are present
  # However, the main POSTGRES_PASSWORD is used by this standalone instance.
  # Supabase has its own environment variables for its internal Postgres if configured differently,
  # but the current docker-compose.yml uses the main POSTGRES_PASSWORD for langfuse's postgres dependency too.
  # For clarity, we will label this distinctly.
  echo
  echo "==================== Standalone PostgreSQL (for n8n, Langfuse, etc.) ====================="
  echo
  echo "Host: ${POSTGRES_HOST:-postgres}"
  echo "Port: ${POSTGRES_PORT:-5432}"
  echo "Database: ${POSTGRES_DB:-postgres}" # This is typically 'postgres' or 'n8n' for n8n, and 'langfuse' for langfuse, but refers to the service.
  echo "User: ${POSTGRES_USER:-postgres}"
  echo "Password: ${POSTGRES_PASSWORD:-<not_set_in_env>}"
  echo "(Note: This is the PostgreSQL instance used by services like n8n and Langfuse.)"
  echo "(It is separate from Supabase's internal PostgreSQL if Supabase is also enabled.)"
fi

echo
echo "======================================================================="
echo

# --- Update Script Info (Placeholder) ---
log_info "To update the services, run the 'update.sh' script: bash ./scripts/update.sh"

# ============================================
# Cloudflare Tunnel Security Notice
# ============================================
if is_profile_active "cloudflare-tunnel"; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔒 CLOUDFLARE TUNNEL SECURITY"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "✅ Cloudflare Tunnel is configured and running!"
  echo ""
  echo "Your services are accessible through Cloudflare's secure network."
  echo "All traffic is encrypted and routed through the tunnel."
  echo ""
  echo "🛡️  RECOMMENDED SECURITY ENHANCEMENT:"
  echo "   For maximum security, close the following ports in your VPS firewall:"
  echo "   • Port 80 (HTTP)"
  echo "   • Port 443 (HTTPS)" 
  echo "   • Port 7687 (Neo4j Bolt)"
  echo ""
  echo "   ⚠️  Only close ports AFTER confirming tunnel connectivity!"
  echo ""
fi

echo
echo "======================================================================"
echo
echo "Next Steps:"
echo "1. Review the credentials above and store them safely."
echo "2. Access the services via their respective URLs (check \`docker compose ps\` if needed)."
echo "3. Configure services as needed (e.g., first-run setup for n8n)."
echo
echo "======================================================================"
echo
log_info "Thank you for using this installer setup!"
echo

exit 0 
