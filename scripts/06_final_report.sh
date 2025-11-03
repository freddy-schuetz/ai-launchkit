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
  echo
  echo "================================= n8n Task Runner ================================="
  log_success "Python Task Runner: ENABLED"
  echo "  📦 Native Python execution in n8n Code nodes"
  echo "  ⚡ Better performance than Pyodide (10-20x faster)"
  echo "  📚 Supports: pandas, numpy, requests, scikit-learn (via custom image)"
  echo "  ⚠️  Breaking Change: Use item[\"json\"] instead of item.json"
  echo "  📖 Migration Guide: See README.md for syntax changes"
fi

if is_profile_active "webhook-testing"; then
  echo
  echo "================================= WEBHOOK TESTING SUITE ==============="
  echo
  echo "============ Webhook Tester (Incoming Webhook Debugger) =============="
  echo "Host: ${WEBHOOK_TESTER_HOSTNAME:-<hostname_not_set>}"
  echo "User: ${WEBHOOK_TESTER_USERNAME:-<not_set_in_env>}"
  echo "Password: ${WEBHOOK_TESTER_PASSWORD:-<not_set_in_env>}"
  echo "URL: https://${WEBHOOK_TESTER_HOSTNAME:-<hostname_not_set>}"
  echo "Internal URL: http://webhook-tester:8080"
  echo
  echo "============ Hoppscotch (API Testing Platform) ======================"
  echo "Host: ${HOPPSCOTCH_HOSTNAME:-<hostname_not_set>}"
  echo "URL: https://${HOPPSCOTCH_HOSTNAME:-<hostname_not_set>}"
  echo "Admin Dashboard: https://${HOPPSCOTCH_HOSTNAME:-<hostname_not_set>}/admin"
  echo "Internal API: http://hoppscotch:3170"
  echo
  echo "⚠️  First-time setup:"
  echo "  1. Visit https://${HOPPSCOTCH_HOSTNAME:-<hostname_not_set>}"
  echo "  2. Create your account with email"
  echo "  3. Check Mailpit for verification email"
  echo "  4. Admin dashboard at /admin (first user = admin)"
  echo
  echo "Documentation: https://docs.hoppscotch.io"
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

if is_profile_active "uptime-kuma"; then
  echo
  echo "================================= Uptime Kuma ========================="
  echo
  echo "Host: ${UPTIME_KUMA_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access:"
  echo "  External (HTTPS): https://${UPTIME_KUMA_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal (Docker): http://uptime-kuma:3001"
  echo
  echo "First Steps:"
  echo "  1. Visit https://${UPTIME_KUMA_HOSTNAME:-<hostname_not_set>}"
  echo "  2. Create your first admin account (first user = admin)"
  echo "  3. Optional: Enable 2FA for extra security"
  echo "  4. Create your first monitor"
  echo "  5. Set up notification channels (Discord, Telegram, Email, etc.)"
  echo
  echo "Public Status Pages:"
  echo "  Create public status pages for your customers"
  echo "  Share uptime information transparently"
  echo "  Configure in Settings → Status Pages"
  echo
  echo "n8n Integration:"
  echo "  Use HTTP Request node with URL: http://uptime-kuma:3001"
  echo "  Webhooks: Configure in monitor settings"
  echo "  API: Generate API token in Settings → API Keys"
  echo
  echo "Documentation: https://github.com/louislam/uptime-kuma/wiki"
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
  echo "  Internal API: http://perplexica:3000"
  echo
  echo "n8n Integration:"
  echo "  API Endpoint: http://perplexica:3000/api/search"
  echo "  Method: POST"
  echo "  Body: {\"query\": \"your search\", \"focusMode\": \"webSearch\", \"chatHistory\": []}"
  echo
  echo "Documentation: https://github.com/ItzCrazyKns/Perplexica"
  echo
  echo "Note: Configure AI providers (OpenAI, Ollama, etc.) via Web UI after first login"
fi

if is_profile_active "research" || is_profile_active "gpt-researcher"; then
  echo
  echo "================================= GPT Researcher ======================="
  echo
  echo "Host: ${GPTR_HOSTNAME:-<hostname_not_set>}"
  echo "User: ${GPTR_USERNAME:-<not_set_in_env>}"
  echo "Password: ${GPTR_PASSWORD:-<not_set_in_env>}"
  echo
  echo "Access:"
  echo "  External (HTTPS): https://${GPTR_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal Backend: http://gpt-researcher:8000"
  echo "  Internal Frontend: http://gpt-researcher-ui:3000"
  echo
  echo "Configuration:"
  echo "  Search: ${GPTR_RETRIEVER:-searx} (using SearXNG)"
  echo "  LLM: ${GPTR_LLM_PROVIDER:-ollama}"
  echo "  Report Length: ${GPTR_TOTAL_WORDS:-2000} words"
  echo "  Format: ${GPTR_REPORT_FORMAT:-APA}"
  echo
  echo "n8n Integration:"
  echo "  HTTP Request node: http://gpt-researcher:8000/api/research"
  echo "  Method: POST"
  echo "  Body: {\"query\": \"your research topic\", \"report_type\": \"research_report\"}"
  echo
  echo "Documentation: https://docs.gptr.dev"
  echo "GitHub: https://github.com/assafelovic/gpt-researcher"
fi

if is_profile_active "research" || is_profile_active "local-deep-research"; then
  echo
  echo "======================= Local Deep Research API ========================"
  echo
  echo "Internal API Only - No Web Interface!"
  echo "Access: http://local-deep-research:2024 (from n8n/containers only)"
  echo
  echo "n8n Integration:"
  echo "  HTTP Request: http://local-deep-research:2024/assistants/search"
  echo "  Method: POST"
  echo "  Body: {\"query\": \"your research topic\"}"
  echo
  echo "LangGraph Studio (external):"
  echo "  Use ngrok or port forwarding to expose port 2024"
  echo
  echo "Documentation: https://github.com/langchain-ai/local-deep-researcher"
fi

# Combined research tips (if both active)
if (is_profile_active "research" || is_profile_active "gpt-researcher") && (is_profile_active "research" || is_profile_active "local-deep-research"); then
  echo
  echo "======================== Research Tools Integration ==================="
  echo
  echo "You have both research tools active! Use them for:"
  echo
  echo "• GPT Researcher: Quick comprehensive reports (2-5 minutes)"
  echo "• Local Deep Research: Detailed iterative analysis (10-20 minutes)"
  echo
  echo "n8n Workflow Ideas:"
  echo "  1. Use GPT Researcher for initial overview"
  echo "  2. Feed results to Local Deep Research for deep dive"
  echo "  3. Combine outputs for comprehensive analysis"
  echo
  echo "Both tools use your existing Ollama and SearXNG installations!"
fi

if is_profile_active "opennotebook"; then
  echo
  echo "======================= Open Notebook =============================="
  echo
  echo "🧠 AI-Powered Knowledge Management & Research Platform"
  echo "Privacy-First Alternative to Google NotebookLM"
  echo
  echo "Host: ${OPENNOTEBOOK_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access:"
  echo "  External (HTTPS): https://${OPENNOTEBOOK_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal API: http://opennotebook:5055 (n8n workflows only)"
  echo
  echo "Authentication:"
  echo "  Password: ${OPENNOTEBOOK_PASSWORD:-<not_set_in_env>}"
  echo "  Note: Native Open Notebook password - enter on first visit"
  echo
  echo "n8n Integration (REST API):"
  echo "  Base URL: http://opennotebook:5055"
  echo "  API Docs: http://opennotebook:5055/docs (Swagger UI)"
  echo "  No auth required for internal Docker network"
  echo
  echo "  Example endpoints:"
  echo "    GET  /api/notebooks - List all notebooks"
  echo "    POST /api/notebooks - Create notebook"
  echo "    POST /api/sources - Upload research content"
  echo "    POST /api/chat - Chat with AI about your content"
  echo
  echo "Data Storage:"
  echo "  Notebooks: ./opennotebook/notebook_data"
  echo "  Database: ./opennotebook/surreal_data (embedded SurrealDB)"
  echo "  Shared: ./shared (for file exchange with other services)"
  echo
  echo "AI Configuration:"
  echo "  Using shared API keys: OPENAI_API_KEY, ANTHROPIC_API_KEY, GROQ_API_KEY"
  echo "  Configure models in Settings → Models (Web UI)"
  echo "  Supports local models via Ollama: http://ollama:11434"
  echo
  echo "Documentation: https://www.open-notebook.ai"
  echo "GitHub: https://github.com/lfnovo/open-notebook"
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
  echo "Resources:"
  echo "  RAM Usage: ~2-4GB (2 workers)"
  echo "  Disk: ~5-10GB initial"
  echo
  echo "Documentation: https://www.odoo.com/documentation/18.0/"
fi

# Twenty CRM Report
if is_profile_active "twenty-crm"; then
  echo
  echo "================================= Twenty CRM =========================="
  echo
  echo "Host: ${TWENTY_CRM_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access:"
  echo "  External (HTTPS): https://${TWENTY_CRM_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal (Docker): http://twenty-crm:3000"
  echo
  echo "Setup:"
  echo "  1. Visit https://${TWENTY_CRM_HOSTNAME:-<hostname_not_set>}"
  echo "  2. Create your first workspace during initial setup"
  echo "  3. Configure workspace settings and invite team members"
  echo
  echo "n8n Integration:"
  echo "  GraphQL Endpoint: http://twenty-crm:3000/graphql"
  echo "  REST API: http://twenty-crm:3000/rest"
  echo "  Note: Generate API key in workspace settings after setup"
  echo
  echo "Documentation: https://twenty.com/developers"
fi

# EspoCRM Report  
if is_profile_active "espocrm"; then
  echo
  echo "================================= EspoCRM ============================="
  echo
  echo "Host: ${ESPOCRM_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Initial Admin Account:"
  echo "  Username: ${ESPOCRM_ADMIN_USERNAME:-admin}"
  echo "  Password: ${ESPOCRM_ADMIN_PASSWORD:-<not_set_in_env>}"
  echo
  echo "Access:"
  echo "  External (HTTPS): https://${ESPOCRM_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal (Docker): http://espocrm:80"
  echo
  echo "Setup:"
  echo "  1. Visit https://${ESPOCRM_HOSTNAME:-<hostname_not_set>}"
  echo "  2. Login with admin credentials above"
  echo "  3. Configure additional users at Administration > Users"
  echo "  4. Set up email integration for campaigns"
  echo
  echo "n8n Integration:"
  echo "  API Endpoint: http://espocrm:80/api/v1/"
  echo "  Authentication: API Key (generate in user preferences)"
  echo "  Webhooks: Administration > Webhooks (for real-time events)"
  echo
  echo "Documentation: https://docs.espocrm.com/"
fi

# Both CRMs active - show integration tips
if is_profile_active "twenty-crm" && is_profile_active "espocrm"; then
  echo
  echo "========================== CRM Integration Tips ====================="
  echo
  echo "Since you have both CRMs active, consider these integration patterns:"
  echo
  echo "• Use Twenty CRM for quick daily customer interactions"
  echo "• Use EspoCRM for detailed analytics and email campaigns"
  echo "• Create n8n workflows to sync data between both systems"
  echo "• Example: New Twenty contact → Auto-create in EspoCRM"
  echo
  echo "n8n Sync Workflow Ideas:"
  echo "  - Two-way contact synchronization"
  echo "  - Opportunity stage updates across both systems"
  echo "  - Unified reporting dashboard combining both CRMs"
fi

if is_profile_active "mautic"; then
  echo
  echo "================================= MAUTIC =============================="
  echo
  echo "Marketing Automation Platform"
  echo
  echo "Access URL: https://${MAUTIC_HOSTNAME:-<hostname_not_set>}"
  echo "Admin Email: ${MAUTIC_ADMIN_EMAIL:-<not_set_in_env>}"
  echo "Admin Password: ${MAUTIC_ADMIN_PASSWORD:-<not_set_in_env>}"
  echo
  echo "API Access (for n8n):"
  echo "  Base URL: https://${MAUTIC_HOSTNAME:-<hostname_not_set>}/api"
  echo "  Internal: http://mautic_web/api"
  echo "  Enable API: Settings → Configuration → API Settings"
  echo "  Create API credentials: Settings → API Credentials"
  echo
  echo "n8n Integration:"
  echo "  1. Add Mautic node in n8n"
  echo "  2. Use URL: http://mautic_web"
  echo "  3. Create OAuth2 credentials in Mautic"
  echo "  4. Configure webhook: http://n8n:5678/webhook/mautic"
  echo
  echo "Initial Setup:"
  echo "  1. Complete installation wizard at https://${MAUTIC_HOSTNAME:-<hostname_not_set>}"
  echo "  2. Configure email settings (Mailpit pre-configured)"
  echo "  3. Import contacts or create forms"
  echo "  4. Build your first campaign"
  echo
  echo "Documentation: https://docs.mautic.org"
  echo "Community: https://forum.mautic.org"
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

if is_profile_active "nocodb"; then
  echo
  echo "================================= NocoDB =============================="
  echo
  echo "🗄️  Open Source Airtable Alternative"
  echo
  echo "Host: ${NOCODB_HOSTNAME:-<hostname_not_set>}"
  echo "Admin Email: ${USER_EMAIL:-<not_set_in_env>}"
  echo "Admin Password: ${NOCODB_ADMIN_PASSWORD:-<not_set_in_env>}"
  echo
  echo "Access Methods:"
  echo "  External (HTTPS): https://${NOCODB_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal (Docker): http://nocodb:8080"
  echo
  echo "n8n Integration:"
  echo "  1. Use HTTP Request node with base URL: http://nocodb:8080"
  echo "  2. API Token: Generate in NocoDB UI under 'API Tokens'"
  echo "  3. Webhooks: Configure in table settings for automation"
  echo
  echo "Quick Start:"
  echo "  1. Login with admin credentials above"
  echo "  2. Create your first base (database)"
  echo "  3. Import data or create tables"
  echo "  4. Share views or collaborate with team"
  echo
  echo "Documentation: https://docs.nocodb.com"
  echo "Community: https://discord.gg/5RgZmkW"
fi

if is_profile_active "seafile"; then
  echo
  echo "================================= Seafile ============================"
  echo
  echo "Host: ${SEAFILE_HOSTNAME:-<hostname_not_set>}"
  echo "Admin Email: ${SEAFILE_ADMIN_EMAIL}"
  echo "Admin Password: ${SEAFILE_ADMIN_PASSWORD:-<not_set>}"
  echo
  echo "Access: https://${SEAFILE_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo "n8n Integration:"
  echo "  Install community node: n8n-nodes-seafile"
  echo "  Internal URL: http://seafile:80"
  echo "  API Docs: https://manual.seafile.com/develop/web_api_v2.1/"
  echo
  echo "Desktop/Mobile Apps:"
  echo "  Download: https://www.seafile.com/en/download/"
  echo
  echo "Documentation: https://manual.seafile.com/"
fi

if is_profile_active "collabora"; then
  echo
  echo "======================= Collabora Online ========================="
  echo
  echo "Host: ${COLLABORA_HOSTNAME:-<hostname_not_set>}"
  echo "Username: ${COLLABORA_USERNAME}"
  echo "Password: ${COLLABORA_PASSWORD:-<not_set>}"
  echo
  echo "Access: https://${COLLABORA_HOSTNAME:-<hostname_not_set>}"
  echo "Internal URL: http://collabora:9980"
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo "🔍 Status Check:"
  echo "  docker ps | grep collabora"
  echo "  docker exec collabora curl -s http://localhost:9980"
  echo "  # Should return: OK"
  echo
  echo "🔗 Seafile Integration:"
  echo "  1. Edit configuration:"
  echo "     docker exec seafile bash -c \"cat >> /shared/seafile/conf/seahub_settings.py << 'EOF'"
  echo ""
  echo "# Collabora Online Integration"
  echo "OFFICE_SERVER_TYPE = 'CollaboraOffice'"
  echo "ENABLE_OFFICE_WEB_APP = True"
  echo "OFFICE_WEB_APP_BASE_URL = 'https://${COLLABORA_HOSTNAME:-<hostname_not_set>}/hosting/discovery'"
  echo "ENABLE_OFFICE_WEB_APP_EDIT = True"
  echo "EOF\""
  echo
  echo "  2. Restart Seafile:"
  echo "     docker compose restart seafile"
  echo
  echo "🤖 n8n Document Conversion:"
  echo "  HTTP Request Node:"
  echo "    Method: POST"
  echo "    URL: http://collabora:9980/cool/convert-to/pdf"
  echo "    Body: multipart-form-data with 'data' field"
  echo
  echo "  Supported conversions:"
  echo "    • DOCX/DOC → PDF, HTML, TXT"
  echo "    • XLSX/XLS → PDF, CSV, HTML"
  echo "    • PPTX/PPT → PDF, PNG, HTML"
  echo
  echo "📊 Monitoring:"
  echo "  Logs: docker logs collabora --tail 50"
  echo "  Stats: docker stats collabora --no-stream"
  echo
  echo "Documentation: https://sdk.collaboraonline.com/"
fi

if is_profile_active "paperless"; then
  echo
  echo "========================== Paperless-ngx ============================"
  echo
  echo "Host: ${PAPERLESS_HOSTNAME:-<hostname_not_set>}"
  echo "Admin User: ${PAPERLESS_ADMIN_EMAIL}"
  echo "Admin Password: ${PAPERLESS_ADMIN_PASSWORD:-<not_set>}"
  echo
  echo "Access: https://${PAPERLESS_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo "Integration:"
  echo "  - Consume folder: ./shared (accessible from Seafile)"
  echo "  - API URL: http://paperless:8000/api/"
  echo "  - API Token: Generate in user settings"
  echo
  echo "Mobile Apps:"
  echo "  - iOS: 'Paperless Mobile'"
  echo "  - Android: 'Paperless Mobile'"
  echo
  echo "Documentation: https://docs.paperless-ngx.com/"
  echo "Community: https://github.com/paperless-ngx/paperless-ngx/discussions"
fi

if is_profile_active "formbricks"; then
  echo
  echo "================================= Formbricks Surveys ==================="
  echo
  echo "🌐 Access URL: https://${FORMBRICKS_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "🔐 Setup Instructions:"
  echo "  1. Open the URL above"
  echo "  2. Click 'Sign up' to create the first admin account"
  echo "  3. First user automatically becomes organization owner"
  echo
  echo "🔌 Integration Endpoints:"
  echo "  Webhook URL: https://${FORMBRICKS_HOSTNAME:-<hostname_not_set>}/api/v1/webhooks"
  echo "  API Base: https://${FORMBRICKS_HOSTNAME:-<hostname_not_set>}/api/v1"
  echo "  Internal (n8n): http://formbricks:3000/api/v1"
  echo
  echo "📝 Survey Types:"
  echo "  ✓ Link Surveys - Share via URL"
  echo "  ✓ Web Surveys - Embed on websites"  
  echo "  ✓ In-App Surveys - Target specific users"
  echo "  ✓ Email Surveys - Send via campaigns"
  echo
  echo "🔗 n8n Integration:"
  echo "  Native Node: Install @formbricks/n8n-nodes-formbricks"
  echo "  Webhook Trigger: Use 'On Response Completed' webhook"
  echo "  API Key: Settings → API Keys (after login)"
  echo
  echo "📚 Documentation: https://formbricks.com/docs"
  echo "💬 Discord: https://formbricks.com/discord"
fi

if is_profile_active "metabase"; then
  echo
  echo "================================= Metabase Analytics ==================="
  echo
  echo "Access URL: https://${METABASE_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Initial Setup:"
  echo "  1. Open the URL above"
  echo "  2. Complete the setup wizard:"
  echo "     - Create admin account"
  echo "     - Add your first data source"
  echo "     - Invite team members"
  echo
  echo "Connect to AI LaunchKit Databases:"
  echo "  ┌─────────────────────────────────────────────────┐"
  echo "  │ n8n PostgreSQL:                                │"
  echo "  │   Host: postgres                               │"
  echo "  │   Port: 5432                                   │"
  echo "  │   Database: n8n                                │"
  echo "  │   Username: ${POSTGRES_USER:-n8n}              │"
  echo "  │   Password: ${POSTGRES_PASSWORD:-<check_env>}  │"
  echo "  ├─────────────────────────────────────────────────┤"
  echo "  │ Supabase PostgreSQL:                           │"
  echo "  │   Host: supabase-db                            │"
  echo "  │   Port: 5432                                   │"
  echo "  │   Database: postgres                           │"
  echo "  │   Username: postgres                           │"
  echo "  │   Password: ${POSTGRES_PASSWORD:-<check_env>}  │"
  echo "  ├─────────────────────────────────────────────────┤"
  echo "  │ Invoice Ninja MySQL:                           │"
  echo "  │   Host: invoiceninja_db                        │"
  echo "  │   Port: 3306                                   │"
  echo "  │   Database: ${INVOICENINJA_DB_NAME:-invoiceninja} │"
  echo "  │   Username: ${INVOICENINJA_DB_USER:-invoiceninja} │"
  echo "  │   Password: ${INVOICENINJA_DB_PASSWORD:-<check_env>} │"
  echo "  ├─────────────────────────────────────────────────┤"
  echo "  │ Kimai MySQL:                                   │"
  echo "  │   Host: kimai_db                               │"
  echo "  │   Port: 3306                                   │"
  echo "  │   Database: ${KIMAI_DB_NAME:-kimai}            │"
  echo "  │   Username: ${KIMAI_DB_USER:-kimai}            │"
  echo "  │   Password: ${KIMAI_DB_PASSWORD:-<check_env>}  │"
  echo "  └────────────────────────────────────────────────┘"
  echo
  echo "API & Embedding:"
  echo "  API Base: https://${METABASE_HOSTNAME:-<hostname_not_set>}/api"
  echo "  Internal: http://metabase:3000/api"
  echo "  Enable embedding in: Admin → Settings → Embedding"
  echo
  echo "Documentation: https://www.metabase.com/docs"
  echo "Learn: https://www.metabase.com/learn"
fi

if is_profile_active "airbyte"; then
  echo
  echo "================================= Airbyte =============================="
  echo
  echo "Web UI Access:"
  echo "  URL:      https://${AIRBYTE_HOSTNAME}"
  echo
  echo "First Login:"
  echo "  - Enter your email address (will be your username)"
  echo "  - Password: ${AIRBYTE_PASSWORD}"
  echo
  echo "Destination Database (for synced data):"
  echo "  Host:     airbyte_destination_db (or ${SERVER_IP} for external access)"
  echo "  Port:     5433"
  echo "  Database: marketing_data"
  echo "  User:     airbyte"
  echo "  Password: ${AIRBYTE_DESTINATION_DB_PASSWORD}"
  echo
  echo "Setup Steps:"
  echo "  1. Log into Airbyte UI at URL above"
  echo "  2. First login: Enter your email + password (above)"
  echo "  3. Add your data sources (Google Ads, Meta, TikTok, etc.)"
  echo "  4. Create destination: PostgreSQL"
  echo "     - Host: airbyte_destination_db (or ${SERVER_IP})"
  echo "     - Port: 5433"
  echo "     - Database: marketing_data"
  echo "     - Username: airbyte"
  echo "     - Password: ${AIRBYTE_DESTINATION_DB_PASSWORD}"
  echo "  5. Create connections (source → destination)"
  echo
  echo "Metabase Integration:"
  echo "  Connect Metabase to the destination database above"
  echo "  to create dashboards on your synced marketing data."
  echo
  echo "n8n Integration:"
  echo "  Trigger syncs via: http://localhost:8001/api/v1/"
  echo
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

if is_profile_active "calcom"; then
  echo
  echo "================================= Cal.com ============================="
  echo
  echo "Host: ${CALCOM_HOSTNAME:-cal.${BASE_DOMAIN}}"
  echo
  echo "Access URL: https://${CALCOM_HOSTNAME:-cal.${BASE_DOMAIN}}"
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo "First Steps:"
  echo "  1. Open the URL above in your browser"
  echo "  2. First user to register becomes admin"
  echo "  3. Configure your availability in Settings"
  echo "  4. Create event types (15min, 30min, 60min meetings)"
  echo "  5. Share your booking link: https://${CALCOM_HOSTNAME}/USERNAME"
  echo
  echo "Email Configuration:"
  echo "  Using: ${MAIL_MODE:-mailpit} (${SMTP_HOST}:${SMTP_PORT})"
  echo "  Bookings will be captured in Mailpit"
  echo
  echo "📚 Documentation:"
  echo "  Setup Guide: ~/ai-launchkit/docs/CALCOM_SETUP.md"
  echo "  - Google Calendar integration instructions"
  echo "  - Zoom, Stripe, MS365 integrations"
  echo "  - Troubleshooting guide"
  echo "  Online: https://github.com/freddy-schuetz/ai-launchkit/blob/main/docs/CALCOM_SETUP.md"  
  echo
  echo "n8n Integration:"
  echo "  Base URL: http://calcom:3000/api/v2"
  echo "  Auth: Generate API key in Settings → Developer → API Keys"
  echo "  Docs: https://api.cal.com/v2/docs"
  echo
  echo "Documentation: https://cal.com/docs"
fi

if is_profile_active "kimai"; then
  echo
  echo "================================= Kimai Time Tracking =================="
  echo
  echo "🌐 Access URL: https://${KIMAI_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "👤 Kimai Admin Account:"
  echo "  Email: ${KIMAI_ADMIN_EMAIL:-<not_set_in_env>}"
  echo "  Password: ${KIMAI_ADMIN_PASSWORD:-<not_set_in_env>}"
  echo
  echo "🔌 Integration Endpoints:"
  echo "  External API: https://${KIMAI_HOSTNAME:-<hostname_not_set>}/api"
  echo "  Internal (n8n): http://kimai:8001/api"
  echo
  echo "👥 User Management:"
  echo "  - First user is Super Admin"
  echo "  - Add users: Settings → Users"
  echo "  - Roles: User, Teamlead, Admin, Super-Admin"
  echo
  echo "📱 Mobile Apps:"
  echo "  iOS: https://apps.apple.com/app/kimai-mobile/id1463807227"
  echo "  Android: https://play.google.com/store/apps/details?id=de.cloudrizon.kimai"
  echo
  echo "📚 Documentation: https://www.kimai.org/documentation/"
  echo "🔧 API Docs: https://${KIMAI_HOSTNAME:-<hostname_not_set>}/api/doc"
fi

if is_profile_active "invoiceninja"; then
  echo
  echo "================================= Invoice Ninja ========================"
  echo
  echo "🌐 Access URL: https://${INVOICENINJA_HOSTNAME:-<hostname_not_set>}/login"
  echo
  echo "⚠️  APP_KEY Status:"
  if [[ -n "${INVOICENINJA_APP_KEY}" ]]; then
    echo "  ✅ APP_KEY is configured"
  else
    echo "  ❌ APP_KEY MISSING! Generate with:"
    echo "     docker run --rm invoiceninja/invoiceninja:5 php artisan key:generate --show"
    echo "     Then add to .env as INVOICENINJA_APP_KEY"
  fi
  echo
  echo "👤 Initial Admin Account:"
  echo "  Email: ${INVOICENINJA_ADMIN_EMAIL:-<not_set_in_env>}"
  echo "  Password: ${INVOICENINJA_ADMIN_PASSWORD:-<not_set_in_env>}"
  echo "  Note: Delete IN_USER_EMAIL and IN_PASSWORD from .env after first login!"
  echo
  echo "🔌 API Endpoints:"
  echo "  External: https://${INVOICENINJA_HOSTNAME:-<hostname_not_set>}/api/v1"
  echo "  Internal (n8n): http://invoiceninja:8000/api/v1"
  echo
  echo "🔗 n8n Integration:"
  echo "  Native node available! Search for 'Invoice Ninja' in n8n"
  echo "  API Token: Settings → Account Management → API Tokens"
  echo
  echo "📚 Documentation: https://invoiceninja.github.io/"
  echo "🎥 Videos: https://www.youtube.com/channel/UCXjmYgQdCTpvHZSQ0x6VFRA"
fi

if is_profile_active "jitsi"; then
  echo
  echo "================================= Jitsi Meet =========================="
  echo
  echo "Host: ${JITSI_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access:"
  echo "  Video Conferencing: https://${JITSI_HOSTNAME:-<hostname_not_set>}"
  echo "  Meeting Rooms: https://${JITSI_HOSTNAME:-<hostname_not_set>}/YourRoomName"
  echo
  echo "⚠️  CRITICAL NETWORK REQUIREMENTS:"
  echo "  - UDP Port 10000 MUST be open for WebRTC media"
  echo "  - Without UDP 10000: Audio/Video will NOT work!"
  echo "  - Current VPS may have UDP issues - test required"
  echo
  echo "Network Configuration:"
  echo "  JVB Host Address: ${JVB_DOCKER_HOST_ADDRESS:-<not_set>}"
  echo "  WebRTC Media Port: 10000/udp"
  echo "  XMPP Domain: ${JITSI_XMPP_DOMAIN:-meet.jitsi}"
  echo
  echo "Security Features (NO Basic Auth):"
  echo "  - Lobby mode for meeting security"
  echo "  - Guest access (no accounts required)"
  echo "  - Optional meeting passwords"
  echo "  - Room-level security instead of site-level auth"
  echo
  echo "Testing:"
  echo "  1. Create test meeting: https://${JITSI_HOSTNAME:-<hostname_not_set>}/test123"
  echo "  2. Join from different devices/networks"
  echo "  3. Verify audio/video works"
  echo
  echo "Cal.com Integration:"
  echo "  1. In Cal.com: Settings → Apps → Jitsi Video"
  echo "  2. Server URL: https://${JITSI_HOSTNAME:-<hostname_not_set>}"
  echo "  3. Meeting links auto-generated for bookings"
  echo
  echo "Documentation: https://jitsi.github.io/handbook/"
fi

if is_profile_active "livekit"; then
  echo
  echo "================================= LiveKit ============================="
  echo
  echo "Real-time Voice & Video Infrastructure (WebRTC SFU Server)"
  echo
  echo "WebSocket URL: wss://${LIVEKIT_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "API Credentials (for client authentication):"
  echo "  API Key: ${LIVEKIT_API_KEY:-<not_set_in_env>}"
  echo "  API Secret: ${LIVEKIT_API_SECRET:-<not_set_in_env>}"
  echo
  echo "Access:"
  echo "  External WebSocket: wss://${LIVEKIT_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal WebSocket: ws://livekit-server:7880"
  echo "  Internal HTTP API: http://livekit-server:7881"
  echo
  echo "⚠️  CRITICAL NETWORK REQUIREMENTS:"
  echo "  - UDP Ports 50000-50100 MUST be open for WebRTC media"
  echo "  - TCP Port 7882 required for fallback"
  echo "  - Without UDP: Audio/Video will NOT work!"
  echo
  echo "Network Configuration:"
  echo "  Media Ports: 50000-50100/udp + 7882/tcp"
  echo "  Node IP: ${JVB_DOCKER_HOST_ADDRESS:-<auto-detected>}"
  echo
  echo "Authentication:"
  echo "  ✓ JWT-based client authentication (no login UI)"
  echo "  ✓ Generate tokens using API Key/Secret"
  echo "  ✓ Tokens must be generated by your backend/n8n"
  echo
  echo "n8n Integration:"
  echo "  1. Install LiveKit SDK: npm install livekit-server-sdk"
  echo "  2. Generate access tokens using API Key/Secret"
  echo "  3. Pass tokens to frontend/client applications"
  echo "  4. Use internal URL: ws://livekit-server:7880"
  echo
  echo "Client SDKs Available:"
  echo "  - JavaScript/TypeScript (Web/React/Vue)"
  echo "  - React Native (iOS/Android)"
  echo "  - Flutter (iOS/Android)"
  echo "  - Swift (iOS/macOS)"
  echo "  - Kotlin/Java (Android)"
  echo
  echo "================================= LiveKit Agents ======================"
  echo
  echo "Voice Agent Status: Running"
  echo "Mode: $(if [[ -n "${OPENAI_API_KEY}" ]]; then echo "OpenAI (Cloud)"; else echo "Local (Ollama/Whisper/TTS)"; fi)"
  echo
  echo "How to use:"
  echo "  1. Create LiveKit room via n8n or API"
  echo "  2. Generate JWT token with API Key/Secret"
  echo "  3. Connect client with token"
  echo "  4. Agent joins automatically and responds to voice"
  echo
  echo "Test Interface: Create file website/voice-test.html"
  echo "n8n JWT Generation: Use JavaScript node with jsonwebtoken"
  echo
  echo "Agent Logs: docker logs livekit-agents -f"
  echo "Documentation: https://docs.livekit.io/"
  echo "SDK Examples: https://github.com/livekit/livekit-examples"
fi

if is_profile_active "vaultwarden"; then
  echo
  echo "================================= Vaultwarden ========================="
  echo
  echo "Host: ${VAULTWARDEN_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access:"
  echo "  Web Vault: https://${VAULTWARDEN_HOSTNAME:-<hostname_not_set>}"
  echo "  Admin Panel: https://${VAULTWARDEN_HOSTNAME:-<hostname_not_set>}/admin"
  echo "  Internal API: http://vaultwarden:80"
  echo
  echo "⚠️  IMPORTANT - Admin Token Required for Admin Panel:"
  echo "  Token: ${VAULTWARDEN_ADMIN_TOKEN:-<not_set>}"
  echo
  echo "First Steps:"
  echo "  1. Access Admin Panel with token above"
  echo "  2. Configure SMTP settings (using Mailpit)"
  echo "  3. Set signup options (disabled by default)"
  echo "  4. Create your first user account"
  echo "  5. Install browser extension/mobile app"
  echo
  echo "Client Configuration:"
  echo "  Browser Extensions: Set server URL to https://${VAULTWARDEN_HOSTNAME:-<hostname_not_set>}"
  echo "  Mobile Apps: Add custom server during setup"
  echo "  Desktop Apps: Configure server URL in preferences"
  echo
  echo "Compatible Clients:"
  echo "  - Bitwarden Browser Extensions (all browsers)"
  echo "  - Bitwarden Mobile Apps (iOS/Android)"
  echo "  - Bitwarden Desktop (Windows/Mac/Linux)"
  echo "  - Bitwarden CLI"
  echo
  echo "Security Features:"
  echo "  - Signups disabled by default (enable in admin)"
  echo "  - Domain whitelist: ${SIGNUPS_DOMAINS_WHITELIST:-not_set}"
  echo "  - 2FA support (TOTP, WebAuthn, Duo, Email)"
  echo "  - Emergency access feature"
  echo "  - Send feature (secure file/text sharing)"
  echo
  echo "SMTP Configuration:"
  echo "  Currently using: ${MAIL_MODE:-mailpit}"
  echo "  Host: ${SMTP_HOST:-mailpit}"
  echo "  Port: ${SMTP_PORT:-1025}"
  echo
  echo "Documentation: https://github.com/dani-garcia/vaultwarden"
fi

if is_profile_active "ai-security"; then
  echo
  echo "================================= AI Security Suite ==================="
  echo
  echo "🛡️  LLM Guard (Prompt Injection Protection)"
  echo "  Internal API: http://llm-guard:8000"
  echo "  API Token: ${LLM_GUARD_TOKEN:-<not_set_in_env>}"
  echo
  echo "🔐  Microsoft Presidio (GDPR-Compliant PII Handling - English)"
  echo "  Analyzer API: http://presidio-analyzer:3000"
  echo "  Anonymizer API: http://presidio-anonymizer:3000"
  echo "  Min Score: ${PRESIDIO_MIN_SCORE:-0.5}"
  echo
  echo "🌍  Flair NER (German/Multi-language PII Detection)"
  echo "  Internal API: http://flair-pii:8000"
  echo "  Models: de-ner-large (German), ner-large (English)"
  echo "  Accuracy: 95%+ for German names/locations"
  echo
  echo "📚  n8n Integration Examples:"
  echo
  echo "  LLM Guard - Pre-processing check:"
  echo "    POST http://llm-guard:8000/analyze/prompt"
  echo "    Headers: { \"Authorization\": \"Bearer \${LLM_GUARD_TOKEN}\" }"
  echo "    Body: { \"prompt\": \"user input text\" }"
  echo
  echo "  Presidio - PII Detection (English):"
  echo "    POST http://presidio-analyzer:3000/analyze"
  echo "    Body: { \"text\": \"...\", \"language\": \"en\" }"
  echo
  echo "  Flair - PII Detection (German/Multi-language):"
  echo "    POST http://flair-pii:8000/analyze"
  echo "    Body: { \"text\": \"...\", \"language\": \"de\" }"
  echo
  echo "  Presidio/Flair - Anonymization:"
  echo "    Presidio: POST http://presidio-anonymizer:3000/anonymize"
  echo "    Flair: POST http://flair-pii:8000/anonymize"
  echo
  echo "💡 Workflow Patterns:"
  echo "  English: User Input → LLM Guard → Presidio → LLM → Output"
  echo "  German: User Input → LLM Guard → Flair → LLM → Output"
  echo "  Hybrid: Use Flair for NER + Presidio for patterns"
  echo
  echo "Documentation:"
  echo "  LLM Guard: https://llm-guard.com/docs"
  echo "  Presidio: https://microsoft.github.io/presidio"
  echo "  Flair: https://github.com/flairNLP/flair"
fi

if is_profile_active "kopia"; then
  echo
  echo "================================= Kopia Backup ========================"
  echo
  echo "Host: ${KOPIA_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "Access:"
  echo "  Web UI: https://${KOPIA_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal API: http://kopia:51515"
  echo
  echo "Kopia Server Credentials:"
  echo "  Username: ${KOPIA_UI_USERNAME:-admin}"
  echo "  Password: ${KOPIA_UI_PASSWORD:-<not_set_in_env>}"
  echo
  echo "Repository Configuration:"
  echo "  Encryption Password: ${KOPIA_PASSWORD:-<not_set_in_env>}"
  echo "  Storage Backend: Nextcloud WebDAV"
  echo "  Nextcloud URL: ${NEXTCLOUD_WEBDAV_URL:-<not_configured>}"
  echo "  Nextcloud User: ${NEXTCLOUD_USERNAME:-<not_configured>}"
  echo
  echo "Backup Sources:"
  echo "  - Docker Volumes: /data/docker-volumes (read-only)"
  echo "  - Shared Directory: /data/shared (read-only)"
  echo "  - AI LaunchKit Config: /data/ai-launchkit (read-only)"
  echo
  echo "First Steps:"
  echo "  1. Access https://${KOPIA_HOSTNAME:-<hostname_not_set>}"
  echo "  2. Login with Kopia UI credentials"
  echo "  3. Create WebDAV repository to Nextcloud"
  echo "  4. Configure backup policies"
  echo "  5. Create first snapshots"
  echo
  echo "CLI Commands:"
  echo "  docker exec kopia kopia snapshot create /data/docker-volumes"
  echo "  docker exec kopia kopia snapshot list"
  echo "  docker exec kopia kopia policy set /data --compression=pgzip"
  echo
  echo "Documentation: https://kopia.io/docs/"
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

# TTS Chatterbox Report
if is_profile_active "tts-chatterbox"; then
  echo
  echo "================================= TTS Chatterbox ======================"
  echo
  echo "🎙️ State-of-the-Art Text-to-Speech with Emotion Control"
  echo
  echo "Host: ${CHATTERBOX_HOSTNAME:-<hostname_not_set>}"
  echo "API Key: ${CHATTERBOX_API_KEY:-<not_set_in_env>}"
  echo "Device: ${CHATTERBOX_DEVICE:-cpu}"
  echo "Emotion Level: ${CHATTERBOX_EXAGGERATION:-0.5} (0.25-2.0)"
  echo
  echo "Access:"
  echo "  External (HTTPS): https://${CHATTERBOX_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal (Docker): http://chatterbox-tts:4123"
  echo
  echo "Web UI Access:"  
  echo "  Frontend: https://${CHATTERBOX_FRONTEND_HOSTNAME:-<hostname_not_set>}"
  echo
  echo "API Endpoints:"
  echo "  OpenAI Compatible: POST /v1/audio/speech"
  echo "  Health Check: GET /health"
  echo "  Voices List: GET /v1/voices"
  echo "  Voice Clone: POST /v1/voice/clone"
  echo
  echo "n8n Integration:"
  echo "  Use HTTP Request node with URL: http://chatterbox-tts:4123/v1/audio/speech"
  echo "  Add header: X-API-Key: \${CHATTERBOX_API_KEY}"
  echo
  echo "Voice Cloning:"
  echo "  1. Place 10-30 second audio samples in: ./shared/tts/voices/"
  echo "  2. Supported formats: wav, mp3, ogg, flac"
  echo "  3. Use voice ID in API calls"
  echo
  echo "Performance:"
  echo "  CPU Mode: ~5-10 seconds per sentence"
  echo "  GPU Mode: <1 second per sentence (set CHATTERBOX_DEVICE=cuda)"
  echo
  echo "Documentation: https://github.com/travisvn/chatterbox-tts-api"
  echo "Model Info: https://www.resemble.ai/chatterbox/"
fi

# Vexa Meeting Transcription Report
if is_profile_active "vexa"; then
  echo
  echo "================================= Vexa (Meeting Transcription) ========"
  echo
  echo "🎙️ Real-time Meeting Transcription API (Google Meet & Teams)"
  echo
  echo "Platform Support:"
  echo "  ✅ Google Meet (Live)"
  echo "  ✅ Microsoft Teams (Live)"
  echo "  ⏳ Zoom (Coming Soon)"
  echo
  echo "Access (via exposed ports):"
  echo "  API Gateway: http://localhost:8056 or http://YOUR_SERVER_IP:8056"
  echo "  Admin API: http://localhost:8057 or http://YOUR_SERVER_IP:8057"
  echo
  echo "Authentication:"
  echo "  User API Key: ${VEXA_API_KEY:-<not_set_in_env>}"
  echo "  Admin Token: ${VEXA_ADMIN_TOKEN:-<not_set_in_env>}"
  echo
  echo "n8n Integration Example (Google Meet):"
  echo "  Method: POST"
  echo "  URL: http://localhost:8056/bots"
  echo "  Headers: { \"X-API-Key\": \"${VEXA_API_KEY}\" }"
  echo "  Body: {"
  echo "    \"platform\": \"google_meet\","
  echo "    \"native_meeting_id\": \"xxx-xxxx-xxx\""
  echo "  }"
  echo
  echo "Get Transcript:"
  echo "  Method: GET"
  echo "  URL: http://localhost:8056/transcripts/google_meet/xxx-xxxx-xxx"
  echo "  Headers: { \"X-API-Key\": \"${VEXA_API_KEY}\" }"
  echo
  echo "Whisper Configuration:"
  echo "  Model: ${VEXA_WHISPER_MODEL:-base}"
  echo "  Device: ${VEXA_WHISPER_DEVICE:-cpu}"
  echo "  Models: tiny (fastest) → base → medium → large (best quality)"
  echo
  echo "⚠️  Note: Vexa runs in separate network. Access via exposed ports only!"
  echo
  echo "Documentation: https://github.com/Vexa-ai/vexa"
fi

if is_profile_active "scriberr"; then
  echo
  echo "================================= Scriberr ============================"
  echo
  echo "🎙️ AI Audio Transcription with Speaker Diarization"
  echo
  echo "Host: ${SCRIBERR_HOSTNAME:-<hostname_not_set>}"
  echo "Whisper Model: ${SCRIBERR_WHISPER_MODEL:-base}"
  echo "Speaker Detection: ${SCRIBERR_SPEAKER_DIARIZATION:-true}"
  echo
  echo "Access:"
  echo "  External (HTTPS): https://${SCRIBERR_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal API: http://scriberr:8080/api"
  echo
  echo "Authentication:"
  echo "  ✓ Scriberr has its own user management"
  echo "  ✓ Create your account on first access"
  echo "  ✓ API keys can be generated in the UI"
  echo
  echo "API Endpoints:"
  echo "  Upload: POST http://scriberr:8080/api/upload"
  echo "  Transcripts: GET http://scriberr:8080/api/transcripts"
  echo "  Summary: POST http://scriberr:8080/api/summary"
  echo
  echo "n8n Integration:"
  echo "  1. Upload audio via HTTP Request node to /api/upload"
  echo "  2. Poll /api/transcripts/{id} for results"
  echo "  3. Shared folder: /data/shared/audio"
  echo
  echo "Model Info:"
  echo "  - tiny: ~1GB RAM, fastest, lower quality"
  echo "  - base: ~1.5GB RAM, good balance (default)"
  echo "  - small: ~3GB RAM, better quality"
  echo "  - medium: ~5GB RAM, high quality"
  echo "  - large: ~10GB RAM, best quality"
  echo
  echo "First start may take 2-5 minutes to download models."
  echo "Documentation: https://github.com/rishikanthc/Scriberr"
fi

if is_profile_active "ocr"; then
  echo
  echo "================================= OCR Bundle ==========================="
  echo
  echo "Two OCR engines are available for text extraction:"
  echo
  echo "▶ Tesseract OCR (Fast Mode):"
  echo "  Internal URL: http://tesseract-ocr:8884"
  echo "  Best for: Clean scans, bulk processing, text-heavy documents"
  echo "  Speed: ~3-4 seconds per image"
  echo "  Supports: 90+ languages"
  echo
  echo "▶ EasyOCR (Quality Mode):"
  echo "  Internal URL: http://easyocr:2000"
  echo "  Secret Key: ${EASYOCR_SECRET_KEY:-<not_set_in_env>}"
  echo "  Best for: Photos, receipts, invoices with numbers, natural images"
  echo "  Speed: ~7-8 seconds per image"
  echo "  Supports: 80+ languages"
  echo
  echo "n8n Integration:"
  echo "  Use HTTP Request node with the URLs above"
  echo "  Tesseract: POST multipart/form-data with 'file' and 'options' fields"
  echo "  EasyOCR: POST application/json with 'image_url' and 'secret_key' fields"
  echo
  echo "Documentation:"
  echo "  Tesseract: https://github.com/hertzg/tesseract-server"
  echo "  EasyOCR: https://github.com/JaidedAI/EasyOCR"
fi

if is_profile_active "stirling-pdf"; then
  echo
  echo "================================= Stirling-PDF ========================"
  echo
  echo "Advanced PDF manipulation with 100+ features"
  echo
  echo "Host: ${STIRLING_HOSTNAME:-<hostname_not_set>}"
  echo "  Initial Login: admin / stirling"
  echo "  Note: You'll be prompted to change password on first login"
  echo
  echo "Access:"
  echo "  External (HTTPS): https://${STIRLING_HOSTNAME:-<hostname_not_set>}"
  echo "  Internal (Docker): http://stirling-pdf:8080"
  echo
  echo "n8n Integration:"
  echo "  Use HTTP Request node with URL: http://stirling-pdf:8080/api/v1"
  echo "  API Docs: http://stirling-pdf:8080/api/v1/docs"
  echo
  echo "Documentation: https://docs.stirlingpdf.com"
  echo "GitHub: https://github.com/Stirling-Tools/Stirling-PDF"
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

if is_profile_active "browser-suite"; then
  echo
  echo "==================== Browser Automation Suite ========================"
  echo
  echo "🌐 Browserless (Chrome Runtime):"
  echo "  Internal WebSocket: ws://browserless:3000?token=${BROWSERLESS_TOKEN:-<not_set>}"
  echo "  Concurrent Sessions: ${BROWSERLESS_CONCURRENT:-10}"
  echo "  Timeout: ${BROWSERLESS_TIMEOUT:-120000}ms"
  echo
  echo "🤖 Skyvern (Vision AI):"
  echo "  Internal API: http://skyvern:8000"
  echo "  API Key: ${SKYVERN_API_KEY:-<not_set>}"
  if [ "${ENABLE_OLLAMA}" = "true" ]; then
    echo "  Mode: LOCAL (Ollama)"
    echo "  Model: ${OLLAMA_MODEL:-qwen2.5:7b-instruct}"
  else
    echo "  Mode: CLOUD (OpenAI)"
    echo "  API Key: ${OPENAI_API_KEY:-<not_set>}"
  fi
  echo
  echo "🧠 Browser-use (LLM Control):"
  echo "  Execute: docker exec browser-use python -c 'your_code'"
  echo "  Script location: ./shared/*.py"
  echo
  echo "📦 n8n Community Nodes to install:"
  echo "  - n8n-nodes-puppeteer (WebSocket: ws://browserless:3000)"
  echo "  - n8n-nodes-browserless"
  echo
  echo "Example n8n usage:"
  echo "  1. Install community nodes in n8n UI"
  echo "  2. Use Puppeteer node with browserless WebSocket"
  echo "  3. For Skyvern: HTTP Request to http://skyvern:8000/v1/execute"
  echo
  echo "Documentation:"
  echo "  Browserless: https://docs.browserless.io"
  echo "  Skyvern: https://docs.skyvern.com"
  echo "  Browser-use: https://github.com/browser-use/browser-use"
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
echo "  User: ${MAILPIT_USERNAME:-<not_set_in_env>}"
echo "  Password: ${MAILPIT_PASSWORD:-<not_set_in_env>}"
echo "  Internal SMTP: mailpit:1025"
echo "  Purpose: Captures all emails for development/testing"
if [[ "$MAIL_MODE" == "mailpit" ]]; then
    echo "  Status: PRIMARY mail handler (no external delivery)"
else
    echo "  Status: Available for testing (not primary)"
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
fi

echo
echo "To switch between mail handlers:"
echo "  1. Edit .env file: MAIL_MODE=mailpit"
echo "  2. Update SMTP_* variables accordingly"
echo "  3. Restart services: docker compose -p localai restart"
echo

echo
echo "======================================================================="
echo

# Docker-Mailserver Report (if selected)
if is_profile_active "mailserver"; then
  echo
  echo "================================= Docker-Mailserver ==================="
  echo
  echo "✅ Production mail server ready for all services"
  echo
  echo "Auto-configured Account:"
  echo "  Email: noreply@${BASE_DOMAIN}"
  echo "  Password: ${MAIL_NOREPLY_PASSWORD:-<check_env_file>}"
  echo
  echo "SMTP Settings (automatically configured for all services):"
  echo "  Host: mailserver (internal)"
  echo "  Port: 587"
  echo "  Security: STARTTLS"
  echo "  User: noreply@${BASE_DOMAIN}"
  echo
  echo "Services using this mail server:"
  echo "  ✓ Cal.com - Appointment notifications"
  echo "  ✓ Baserow - User invitations"
  echo "  ✓ Odoo - All email features"
  echo "  ✓ n8n - Email nodes"
  echo "  ✓ Supabase - Auth emails"
  echo
  echo "⚠️  IMPORTANT: Configure these DNS records:"
  echo
  echo "1. MX Record:"
  echo "   Type: MX"
  echo "   Name: ${BASE_DOMAIN}"
  echo "   Value: mail.${BASE_DOMAIN}"
  echo "   Priority: 10"
  echo
  echo "2. A Record for mail subdomain:"
  echo "   Type: A"
  echo "   Name: mail"
  echo "   Value: YOUR_SERVER_IP"
  echo
  echo "3. SPF Record:"
  echo "   Type: TXT"
  echo "   Name: @"
  echo "   Value: \"v=spf1 mx ~all\""
  echo
  echo "4. DMARC Record:"
  echo "   Type: TXT"
  echo "   Name: _dmarc"
  echo "   Value: \"v=DMARC1; p=none; rua=mailto:postmaster@${BASE_DOMAIN}\""
  echo
  echo "5. DKIM Record:"
  # Check if DKIM was generated during installation
  if [ -f "dkim_record.txt" ]; then
    echo "   ✅ DKIM KEY AUTOMATICALLY GENERATED!"
    echo ""
    echo "   Copy this ENTIRE record to your DNS as TXT record:"
    echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat dkim_record.txt | sed 's/^/   /'
    echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "   DNS Record Name: mail._domainkey.${BASE_DOMAIN}"
    echo "   Type: TXT"
  else
    echo "   ⚠️  DKIM not generated automatically"
    echo "   Run manually: docker exec mailserver setup config dkim"
    echo "   Then copy the output to DNS"
  fi
  echo
  echo "Commands:"
  echo "  Add user: docker exec -it mailserver setup email add user@${BASE_DOMAIN}"
  echo "  List users: docker exec -it mailserver setup email list"
  echo "  DKIM setup: docker exec mailserver setup config dkim"
  echo "  View logs: docker logs mailserver"
  echo
  echo "Documentation: https://docker-mailserver.github.io/docker-mailserver/"
fi

# SnappyMail Webmail Report (if selected)
if is_profile_active "snappymail"; then
  echo
  echo "================================= SnappyMail Webmail =================="
  echo
  echo "✅ Modern webmail interface ready"
  echo
  echo "Access:"
  echo "  URL: https://${SNAPPYMAIL_HOSTNAME:-webmail.${BASE_DOMAIN}}"
  echo "  Admin Panel: https://${SNAPPYMAIL_HOSTNAME:-webmail.${BASE_DOMAIN}}/?admin"
  echo
  echo "⚠️  IMPORTANT - Get Admin Password:"
  echo "  The admin password is auto-generated on first start."
  echo "  Run this command to see it:"
  echo "  docker exec snappymail cat /var/lib/snappymail/_data_/_default_/admin_password.txt"
  echo
  echo "First Time Setup:"
  echo "  1. Get admin password with command above"
  echo "  2. Login to admin panel: /?admin"
  echo "  3. Username: admin"
  echo "  4. Go to Domains → Add Domain"
  echo "  5. Add domain: ${BASE_DOMAIN}"
  echo "  6. IMAP Server: mailserver"
  echo "  7. IMAP Port: 143"
  echo "  8. SMTP Server: mailserver"
  echo "  9. SMTP Port: 587"
  echo "  10. Use STARTTLS for both"
  echo
  echo "Users can then login with:"
  echo "  Email: their-email@${BASE_DOMAIN}"
  echo "  Password: their Docker-Mailserver password"
  echo
  echo "Documentation: https://github.com/the-djmaze/snappymail/wiki"
# Auto-configure domain if setup script exists
  if [ -f "$SCRIPT_DIR/setup_snappymail.sh" ]; then
    log_info "Checking SnappyMail domain configuration..."
    bash $SCRIPT_DIR/setup_snappymail.sh
  fi
fi

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
