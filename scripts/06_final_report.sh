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

if is_profile_active "vikunja"; then
  echo
  echo "================================= Vikunja ============================="
  echo
  echo "Host: ${VIKUNJA_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access URL: https://${VIKUNJA_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo "First Steps:"
  echo "  1. Open the URL above in your browser"
  echo "  2. Click 'Register' to create your first account"
  echo "  3. This first account will have admin privileges"
  echo "  4. Start creating projects and tasks"
  echo
  echo "n8n Integration:"
  echo "  Base URL: http://vikunja:3456/api/v1"
  echo "  Auth: Get API token from User Settings after login"
  echo "  Docs: https://vikunja.io/docs/api/"
  echo
  echo "Mobile Apps:"
  echo "  iOS: App Store - 'Vikunja Cloud'"
  echo "  Android: Play Store - 'Vikunja'"
  echo "  PWA: Use the web app on mobile (installable)"
  echo
  echo "Import Your Data:"
  echo "  From: Todoist, Trello, Microsoft To-Do, Asana (CSV)"
  echo "  Go to: Settings -> Import after login"
  echo
  echo "CalDAV Support:"
  echo "  URL: https://${VIKUNJA_HOSTNAME:-<hostname>}/dav"
  echo "  For calendar apps like Thunderbird, Apple Calendar"
  echo
  echo "Documentation: https://vikunja.io/docs"
  echo "Community: https://community.vikunja.io"
fi

# MySQL Report (only if installed for Leantime)
if is_profile_active "mysql" && is_profile_active "leantime"; then
  echo
  echo "================================= MySQL 8.4 ==========================="
  echo
  echo "Status: Installed automatically for Leantime"
  echo "Container: mysql_leantime"
  echo "Port: 3306 (internal only)"
  echo
  echo "Root Password: ${MYSQL_ROOT_PASSWORD:-<not_set_in_env>}"
  echo
  echo "Databases:"
  echo "  - leantime (created automatically)"
  echo
  echo "This MySQL instance can also be used for:"
  echo "  - WordPress (create DB: wordpress)"
  echo "  - Ghost (create DB: ghost)"
  echo "  - Matomo (create DB: matomo)"
  echo "  - Any other MySQL-compatible application"
  echo
  echo "To create additional databases:"
  echo "  docker exec -it mysql_leantime mysql -uroot -p"
  echo "  CREATE DATABASE dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  echo "  CREATE USER 'username'@'%' IDENTIFIED BY 'password';"
  echo "  GRANT ALL PRIVILEGES ON dbname.* TO 'username'@'%';"
  echo "  FLUSH PRIVILEGES;"
fi

# Leantime Report
if is_profile_active "leantime"; then
  echo
  echo "================================= Leantime ============================"
  echo
  echo "Host: ${LEANTIME_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access URL: https://${LEANTIME_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo "First Steps:"
  echo "  1. Open the URL above in your browser"
  echo "  2. The installation wizard will start automatically"
  echo "  3. Create your admin account (first user = admin)"
  echo "  4. Complete company setup"
  echo "  5. Start with a Goal Canvas to define objectives"
  echo
  echo "n8n Integration:"
  echo "  Base URL: http://leantime:8080"
  echo "  API Docs: https://docs.leantime.io/api"
  echo "  Note: API key needed (generate in user settings)"
  echo
  echo "Import/Export:"
  echo "  Import: CSV format from other tools"
  echo "  Export: Excel, CSV for reports"
  echo
  echo "Documentation: https://docs.leantime.io"
  echo "Community: https://discord.gg/4zMzJtAq9z"
  echo "Forum: https://community.leantime.io"
fi

if is_profile_active "easyappointments"; then
  echo
  echo "================================= Easy!Appointments ==================="
  echo
  echo "Host: ${EASYAPPOINTMENTS_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access URL: https://${EASYAPPOINTMENTS_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo "First Steps:"
  echo "  1. Open the URL above in your browser"
  echo "  2. The installation wizard will start automatically"
  echo "  3. Database is already configured (using MySQL)"
  echo "  4. Create your first user (becomes admin)"
  echo "  5. Configure services, providers and business hours"
  echo
  echo "n8n Integration:"
  echo "  Internal URL: http://easyappointments:80"
  echo "  API Docs: https://developers.easyappointments.org"
  echo "  Webhooks: Configure in Settings -> Webhooks"
  echo
  echo "Email Notifications:"
  echo "  Status: Configured (via ${MAIL_MODE})"
  echo "  Test: Book an appointment to verify email delivery"
  echo
  echo "Documentation: https://docs.easyappointments.org"
  echo "Community: https://groups.google.com/g/easy-appointments"
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

# ============================================================================
# MAIL SERVICES
# ============================================================================
echo
echo "================================= Mail System ========================="
echo

# Get mail mode from .env
MAIL_MODE=$(grep "^MAIL_MODE=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d "'")
BASE_DOMAIN=$(grep "^BASE_DOMAIN=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d "'")

echo "Active Mail Handler: ${MAIL_MODE^^}"
echo

# Always show Mailpit info (it's always running)
echo "📬 Mailpit (Mail Catcher) - ACTIVE"
echo "  Web UI: https://${MAILPIT_HOSTNAME:-mail.${BASE_DOMAIN}}"
echo "  Internal SMTP: mailpit:1025"
echo "  Purpose: Captures all emails for development/testing"
if [[ "$MAIL_MODE" == "mailpit" ]]; then
    echo "  Status: PRIMARY mail handler (no external delivery)"
else
    echo "  Status: Available for testing (not primary)"
fi
echo

# Show Postal info if profile is active
if is_profile_active "postal"; then
    echo "📮 Postal (Production Mail Server) - ACTIVE"
    echo "  Admin UI: https://${POSTAL_HOSTNAME:-postal.${BASE_DOMAIN}}"
    echo "  Username: ${POSTAL_USERNAME:-<not_set>}"
    echo "  Password: ${POSTAL_PASSWORD:-<not_set>}"
    echo "  Internal SMTP: postal:25"
    echo
    echo "  ⚠️  First-time setup required:"
    echo "     1. Access the Admin UI"
    echo "     2. Create organization and mail server"
    echo "     3. Configure DNS records (check Postal UI for details)"
    echo "     4. Generate API credentials for services"
    echo
    if [[ "$MAIL_MODE" == "postal" ]]; then
        echo "  Status: PRIMARY mail handler (real delivery enabled)"
    else
        echo "  Status: Installed but not primary"
    fi
fi

echo
echo "Current SMTP Configuration for all services:"
echo "  Mode: ${MAIL_MODE}"
echo "  Host: ${SMTP_HOST}"
echo "  Port: ${SMTP_PORT}"
echo "  User: ${SMTP_USER}"
echo "  From: ${SMTP_FROM}"
echo

if [[ "$MAIL_MODE" == "mailpit" ]]; then
    echo "ℹ️  All emails are captured locally and visible in Mailpit"
    echo "   No emails will be sent externally!"
elif [[ "$MAIL_MODE" == "postal" ]]; then
    echo "ℹ️  Real email delivery is enabled via Postal"
    echo "   Make sure DNS records are properly configured!"
fi

echo
echo "To switch between mail handlers:"
echo "  1. Edit .env file: MAIL_MODE=mailpit or MAIL_MODE=postal"
echo "  2. Update SMTP_* variables accordingly"
echo "  3. Restart services: docker compose -p localai restart"
echo

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
