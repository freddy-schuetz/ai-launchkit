#!/bin/bash

# Source utilities
source "$(dirname "$0")/utils.sh"

# Get script and project directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

# Function to check if a profile is active
is_profile_active() {
    local profile="$1"
    [[ ",$COMPOSE_PROFILES," == *",$profile,"* ]]
}

# Function to generate UUID v4
generate_uuid() {
    if command -v uuidgen &> /dev/null; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    elif [ -f /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid
    else
        # Fallback: generate pseudo-UUID
        printf '%04x%04x-%04x-%04x-%04x-%04x%04x%04x\n' \
            $RANDOM $RANDOM $RANDOM \
            $((RANDOM & 0x0fff | 0x4000)) \
            $((RANDOM & 0x3fff | 0x8000)) \
            $RANDOM $RANDOM $RANDOM
    fi
}

# Function to properly escape JSON strings
escape_json() {
    local input="$1"
    # Escape backslashes first, then quotes, then newlines, tabs, etc.
    echo "$input" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/\t/\\t/g' | sed 's/\r/\\r/g'
}

# Main function
generate_vaultwarden_json() {
    # Check if Vaultwarden is active
    if ! is_profile_active "vaultwarden"; then
        log_info "Vaultwarden is not selected. Skipping credential export."
        return 0
    fi

    # Load environment variables
    if [ ! -f "$ENV_FILE" ]; then
        log_error "No .env file found at $ENV_FILE"
        return 1
    fi
    
    set -a
    source "$ENV_FILE"
    set +a

    log_info "Generating Vaultwarden import file..."

    local json_file="$PROJECT_ROOT/ai-launchkit-credentials.json"
    local folder_id=$(generate_uuid)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

    # Start JSON structure
    cat > "$json_file" << EOF
{
  "encrypted": false,
  "folders": [
    {
      "id": "$folder_id",
      "name": "AI LaunchKit Services"
    }
  ],
  "items": [
EOF

    local items_json=""
    
    # Helper function to add a login item
    add_login_item() {
        local name="$1"
        local username="$2"
        local password="$3"
        local url="$4"
        local notes="$5"
        
        if [[ -z "$username" || -z "$password" ]]; then
            return
        fi
        
        # Escape all string values
        name=$(escape_json "$name")
        username=$(escape_json "$username")
        password=$(escape_json "$password")
        url=$(escape_json "$url")
        notes=$(escape_json "$notes")
        
        local item_id=$(generate_uuid)
        
        # Add comma if not first item
        if [[ -n "$items_json" ]]; then
            items_json="${items_json},"$'\n'
        fi
        
        items_json="${items_json}    {
      \"id\": \"$item_id\",
      \"organizationId\": null,
      \"folderId\": \"$folder_id\",
      \"type\": 1,
      \"reprompt\": 0,
      \"name\": \"$name\",
      \"notes\": \"$notes\",
      \"favorite\": false,
      \"login\": {
        \"username\": \"$username\",
        \"password\": \"$password\",
        \"totp\": null,
        \"passwordRevisionDate\": null,
        \"uris\": [
          {
            \"match\": null,
            \"uri\": \"$url\"
          }
        ]
      },
      \"collectionIds\": [],
      \"revisionDate\": \"$timestamp\"
    }"
    }

    # Helper function to add a secure note
    add_secure_note() {
        local name="$1"
        local notes="$2"
        
        if [[ -z "$notes" ]]; then
            return
        fi
        
        # Escape all string values
        name=$(escape_json "$name")
        notes=$(escape_json "$notes")
        
        local item_id=$(generate_uuid)
        
        # Add comma if not first item
        if [[ -n "$items_json" ]]; then
            items_json="${items_json},"$'\n'
        fi
        
        items_json="${items_json}    {
      \"id\": \"$item_id\",
      \"organizationId\": null,
      \"folderId\": \"$folder_id\",
      \"type\": 2,
      \"reprompt\": 0,
      \"name\": \"$name\",
      \"notes\": \"$notes\",
      \"favorite\": false,
      \"secureNote\": {
        \"type\": 0
      },
      \"collectionIds\": [],
      \"revisionDate\": \"$timestamp\"
    }"
    }

    # Add all service logins
    
    # n8n
    if is_profile_active "n8n"; then
        add_login_item \
            "n8n Workflow Automation" \
            "admin" \
            "CreateOnFirstLogin123!" \
            "https://${N8N_HOSTNAME}" \
            "Main workflow automation platform. Create admin account on first access."
    fi

    # Flowise
    if is_profile_active "flowise"; then
        add_login_item \
            "Flowise AI Agent Builder" \
            "${FLOWISE_USERNAME}" \
            "${FLOWISE_PASSWORD}" \
            "https://${FLOWISE_HOSTNAME}" \
            "Low-code AI agent and chatbot builder"
    fi

    # Bolt.diy
    if is_profile_active "bolt"; then
        add_login_item \
            "Bolt.diy AI Web Development" \
            "${BOLT_USERNAME}" \
            "${BOLT_PASSWORD}" \
            "https://${BOLT_HOSTNAME}" \
            "AI-powered web development in the browser. Protected with Basic Auth."
    fi

    # Open WebUI
    if is_profile_active "open-webui"; then
        add_login_item \
            "Open WebUI (ChatGPT Clone)" \
            "admin@example.com" \
            "ChooseYourPassword123!" \
            "https://${WEBUI_HOSTNAME}" \
            "Self-hosted ChatGPT-like interface. Create account on first access."
    fi

    # Mailpit
    add_login_item \
        "Mailpit Mail Catcher" \
        "${MAILPIT_USERNAME}" \
        "${MAILPIT_PASSWORD}" \
        "https://${MAILPIT_HOSTNAME}" \
        "Mail catcher for development/testing. All emails sent by services are captured here. Protected with Basic Auth."

    # Kopia
    if is_profile_active "kopia"; then
        add_login_item \
            "Kopia Backup Server" \
            "${KOPIA_UI_USERNAME}" \
            "${KOPIA_UI_PASSWORD}" \
            "https://${KOPIA_HOSTNAME}" \
            "Enterprise backup solution with Nextcloud WebDAV storage. Repository password: ${KOPIA_PASSWORD}"
        
        add_secure_note \
            "Kopia Repository Settings" \
            "Repository Password: ${KOPIA_PASSWORD}\\nNextcloud WebDAV:\\nURL: ${NEXTCLOUD_WEBDAV_URL}\\nUsername: ${NEXTCLOUD_USERNAME}\\nApp Password: ${NEXTCLOUD_APP_PASSWORD}\\nIMPORTANT: Repository password is different from UI password!"
    fi

    # Kimai Time Tracking
    if is_profile_active "kimai"; then
        add_login_item \
            "Kimai Time Tracking" \
            "${KIMAI_ADMIN_EMAIL}" \
            "${KIMAI_ADMIN_PASSWORD}" \
            "https://${KIMAI_HOSTNAME}" \
            "Professional time tracking system. DSGVO-compliant with 2FA support. First user is Super Admin. Internal API: http://kimai:8001/api"
    fi

    # Invoice Ninja
    if is_profile_active "invoiceninja"; then
        add_login_item \
            "Invoice Ninja Professional Invoicing" \
            "${INVOICENINJA_ADMIN_EMAIL}" \
            "${INVOICENINJA_ADMIN_PASSWORD}" \
            "https://${INVOICENINJA_HOSTNAME}/login" \
            "Professional invoicing platform with 40+ payment gateways. Initial admin account - delete IN_USER_EMAIL and IN_PASSWORD from .env after first login. Generate API tokens in Settings → Account Management → API Tokens for n8n integration."
        
        # Add APP_KEY as secure note if it exists
        if [[ -n "${INVOICENINJA_APP_KEY}" ]]; then
            add_secure_note \
                "Invoice Ninja APP_KEY" \
                "APP_KEY: ${INVOICENINJA_APP_KEY}\\nCRITICAL: This key encrypts your data. Never lose it! Required for application to run."
        fi
    fi

    # Grafana
    if is_profile_active "monitoring"; then
        add_login_item \
            "Grafana Monitoring" \
            "admin" \
            "${GRAFANA_ADMIN_PASSWORD}" \
            "https://${GRAFANA_HOSTNAME}" \
            "System monitoring dashboards and metrics visualization"
        
        add_login_item \
            "Prometheus Metrics" \
            "${PROMETHEUS_USERNAME}" \
            "${PROMETHEUS_PASSWORD}" \
            "https://${PROMETHEUS_HOSTNAME}" \
            "Time-series metrics database. Protected with Basic Auth."
    fi

    # ComfyUI
    if is_profile_active "comfyui"; then
        add_login_item \
            "ComfyUI Stable Diffusion" \
            "${COMFYUI_USERNAME}" \
            "${COMFYUI_PASSWORD}" \
            "https://${COMFYUI_HOSTNAME}" \
            "Node-based Stable Diffusion UI. Protected with Basic Auth."
    fi

    # Supabase
    if is_profile_active "supabase"; then
        add_login_item \
            "Supabase Studio" \
            "${DASHBOARD_USERNAME}" \
            "${DASHBOARD_PASSWORD}" \
            "https://${SUPABASE_HOSTNAME}" \
            "Backend as a Service - Database, Auth, Storage, Realtime"
    fi

    # Odoo
    if is_profile_active "odoo"; then
        add_secure_note \
            "Odoo ERP/CRM Setup" \
            "URL: https://${ODOO_HOSTNAME}\\nFirst Login Setup:\\nMaster Password: ${ODOO_MASTER_PASSWORD}\\nDatabase Name: odoo\\nAdmin Email: Use your email\\nAdmin Password: Create a strong password\\nDatabase Management Protected with:\\nUsername: ${ODOO_USERNAME}\\nPassword: ${ODOO_PASSWORD}"
    fi

    # Twenty CRM
    if is_profile_active "twenty-crm"; then
        add_secure_note \
            "Twenty CRM Setup" \
            "URL: https://${TWENTY_CRM_HOSTNAME}\\nModern Notion-like CRM\\nFirst-time setup:\\n1. Visit URL above\\n2. Create your first workspace\\n3. Configure workspace settings\\n4. Generate API key for integrations\\n\\nAPI Endpoints:\\nGraphQL: http://twenty-crm:3000/graphql\\nREST: http://twenty-crm:3000/rest\\n\\nFeatures:\\n- Kanban pipeline management\\n- Modern UI similar to Notion\\n- GraphQL + REST APIs\\n- Ideal for startups and small teams"
    fi

    # EspoCRM
    if is_profile_active "espocrm"; then
        add_login_item \
            "EspoCRM Professional CRM" \
            "${ESPOCRM_ADMIN_USERNAME}" \
            "${ESPOCRM_ADMIN_PASSWORD}" \
            "https://${ESPOCRM_HOSTNAME}" \
            "Full-featured CRM with workflows and automation. Admin account pre-configured. Create additional users at Administration > Users. API endpoint: http://espocrm:80/api/v1/ - Generate API key in user preferences for n8n integration."
    fi

    # Mautic
    if is_profile_active "mautic"; then
        add_login_item \
            "Mautic Marketing Automation" \
            "${MAUTIC_ADMIN_EMAIL}" \
            "${MAUTIC_ADMIN_PASSWORD}" \
            "https://${MAUTIC_HOSTNAME}" \
            "Marketing Automation Platform with lead management, email campaigns, landing pages, and analytics. Admin account uses your email. After login: Enable API in Settings → Configuration → API Settings. Create OAuth2 credentials for n8n integration. Internal API: http://mautic_web/api"
    fi

    # Formbricks
    if is_profile_active "formbricks"; then
        add_secure_note \
            "Formbricks Survey Platform" \
            "URL: https://${FORMBRICKS_HOSTNAME}\\nPrivacy-first survey platform (Typeform alternative)\\nFirst user to register becomes organization owner.\\nNo pre-configured credentials - create account on first access.\\nAPI Integration:\\n- Generate API key in Settings → API Keys after login\\n- Webhook URL: https://${FORMBRICKS_HOSTNAME}/api/v1/webhooks\\n- Internal API: http://formbricks:3000/api/v1"
    fi

    # Metabase
    if is_profile_active "metabase"; then
        add_secure_note \
            "Metabase Business Intelligence" \
            "URL: https://${METABASE_HOSTNAME}\\nNo-code business intelligence platform\\nFirst-time setup:\\n1. Open URL above\\n2. Complete setup wizard\\n3. Create admin account\\n4. Add data sources\\nConnect to AI LaunchKit databases:\\n- n8n PostgreSQL: postgres:5432\\n- Supabase: supabase-db:5432\\n- Invoice Ninja MySQL: invoiceninja_db:3306\\n- Kimai MySQL: kimai_db:3306\\nFeatures: Visual query builder, X-Ray insights, dashboards, scheduled reports"
    fi

    # Baserow
    if is_profile_active "baserow"; then
        add_secure_note \
            "Baserow (Airtable Alternative)" \
            "URL: https://${BASEROW_HOSTNAME}\\nFirst user to register becomes admin.\\nNo pre-configured credentials - create account on first access."
    fi

    # NocoDB
    if is_profile_active "nocodb"; then
        add_login_item \
            "NocoDB (Airtable Alternative)" \
            "${USER_EMAIL}" \
            "${NOCODB_ADMIN_PASSWORD}" \
            "https://${NOCODB_HOSTNAME}" \
            "Open-source Airtable alternative with smart spreadsheet UI. Admin account uses your email address. Generate API tokens in user settings for n8n integration. Internal API: http://nocodb:8080"
    fi

    # Perplexica
    if is_profile_active "perplexica"; then
        add_login_item \
            "Perplexica AI Search" \
            "${PERPLEXICA_USERNAME}" \
            "${PERPLEXICA_PASSWORD}" \
            "https://${PERPLEXICA_HOSTNAME}" \
            "Open-source Perplexity AI alternative. Protected with Basic Auth."
    fi

    # Add important secure notes
    
    # Vaultwarden Admin Token
    if [[ -n "$VAULTWARDEN_ADMIN_TOKEN" ]]; then
        add_secure_note \
            "Vaultwarden Admin Token" \
            "Admin Panel: https://${VAULTWARDEN_HOSTNAME}/admin\\nAdmin Token: ${VAULTWARDEN_ADMIN_TOKEN}\\nUse this token to access the Vaultwarden admin panel for server configuration, user management, and SMTP settings."
    fi

    # OCR Services
    if is_profile_active "ocr"; then
        add_secure_note \
            "OCR Bundle (Tesseract + EasyOCR)" \
            "Internal services for text extraction from images/PDFs\\n\\nTesseract OCR (Fast Mode):\\nURL: http://tesseract-ocr:8884\\nMethod: POST multipart/form-data\\nFields: 'file' and 'options'\\nBest for: Clean scans, bulk processing\\n\\nEasyOCR (Quality Mode):\\nURL: http://easyocr:2000\\nSecret Key: ${EASYOCR_SECRET_KEY}\\nMethod: POST application/json\\nBody: {\"image_url\": \"...\", \"secret_key\": \"...\"}\\nBest for: Photos, receipts, handwriting\\n\\nn8n Integration: Use HTTP Request node with above URLs"
    fi

    # Scriberr
    if is_profile_active "scriberr"; then
        add_secure_note \
            "Scriberr AI Audio Transcription" \
            "URL: https://${SCRIBERR_HOSTNAME}\\nAI-powered audio transcription with WhisperX and speaker diarization.\\n\\nScriberr has its own authentication system:\\n- Create account on first access\\n- Generate API keys in the UI for automation\\n\\nModel: ${SCRIBERR_WHISPER_MODEL}\\nInternal API: http://scriberr:8080/api\\n\\nFeatures:\\n- Speaker detection (who said what)\\n- YouTube link transcription\\n- AI summaries with OpenAI/Anthropic"
    fi

    # TTS Chatterbox
    if is_profile_active "tts-chatterbox"; then
        add_secure_note \
            "TTS Chatterbox - Advanced Text-to-Speech" \
            "URL: https://${CHATTERBOX_HOSTNAME}\\nAPI Key: ${CHATTERBOX_API_KEY}\\nDevice: ${CHATTERBOX_DEVICE:-cpu}\\nEmotion Level: ${CHATTERBOX_EXAGGERATION:-0.5}\\n\\nAPI Endpoints:\\n- OpenAI Compatible: POST /v1/audio/speech\\n- Health: GET /health\\n- Voices: GET /v1/voices\\n- Clone: POST /v1/voice/clone\\n\\nInternal Access: http://chatterbox-tts:4123\\n\\nn8n Integration:\\nHTTP Request node: http://chatterbox-tts:4123/v1/audio/speech\\nHeader: X-API-Key: ${CHATTERBOX_API_KEY}\\n\\nVoice Cloning:\\n1. Place samples in ./shared/tts/voices/\\n2. 10-30 second audio files\\n3. Formats: wav, mp3, ogg, flac\\n\\nPerformance: Outperforms ElevenLabs with emotion control"
    fi

    # Stirling-PDF
    if is_profile_active "stirling-pdf"; then
        add_login_item \
            "Stirling-PDF Document Tools" \
            "${STIRLING_USERNAME}" \
            "${STIRLING_PASSWORD}" \
            "https://${STIRLING_HOSTNAME}" \
            "Advanced PDF manipulation with 100+ features. Merge, split, OCR, sign, watermark, convert. Internal API: http://stirling-pdf:8080/api/v1"
    fi

    # Database Credentials
    add_secure_note \
        "PostgreSQL Database (Internal)" \
        "Host: postgres\\nPort: 5432\\nDatabase: ${POSTGRES_DB}\\nUsername: ${POSTGRES_USER}\\nPassword: ${POSTGRES_PASSWORD}\\nUsed by: n8n, Supabase, Langfuse, and other services"

    # API Keys
    if [[ -n "$OPENAI_API_KEY" ]]; then
        add_secure_note \
            "OpenAI API Key" \
            "API Key: ${OPENAI_API_KEY}\\nUsed by:\\n- n8n AI nodes\\n- Open WebUI models\\n- Flowise OpenAI integrations\\n- Supabase AI features"
    fi

    if [[ -n "$ANTHROPIC_API_KEY" ]]; then
        add_secure_note \
            "Anthropic API Key" \
            "API Key: ${ANTHROPIC_API_KEY}\\nUsed by:\\n- bolt.diy Claude models\\n- n8n Claude nodes\\n- Open WebUI Anthropic models"
    fi

    # Server Access Info
    add_secure_note \
        "AI LaunchKit Server Access" \
        "Domain: ${USER_DOMAIN_NAME}\\nServer IP: $(curl -s ifconfig.me 2>/dev/null || echo 'Unknown')\\nSSH Access:\\nssh $(whoami)@${USER_DOMAIN_NAME}\\nDocker Commands:\\ndocker ps\\ndocker logs <container>\\ndocker restart <container>\\nUpdate AI LaunchKit:\\ncd ~/ai-launchkit\\nsudo bash ./scripts/update.sh"

    # Write items to file
    echo "$items_json" >> "$json_file"

    # Close JSON structure
    cat >> "$json_file" << EOF

  ]
}
EOF

    # Create download instructions file
    cat > "$PROJECT_ROOT/VAULTWARDEN_IMPORT.txt" << 'EOF'
AI LAUNCHKIT VAULTWARDEN IMPORT INSTRUCTIONS
============================================

Your credentials file has been generated:
  📁 ai-launchkit-credentials.json

HOW TO DOWNLOAD THE FILE FROM YOUR VPS:
----------------------------------------

Option 1: Using SCP (from your local computer):
  scp username@your-server:/home/username/ai-launchkit/ai-launchkit-credentials.json ./

Option 2: Using Python HTTP Server (temporary):
  # On VPS:
  cd ~/ai-launchkit
  python3 -m http.server 8888
  
  # On local computer:
  wget http://your-server-ip:8888/ai-launchkit-credentials.json
  # Then immediately stop the Python server (Ctrl+C)

Option 3: Using cat and copy-paste (for small files):
  # On VPS:
  cat ~/ai-launchkit/ai-launchkit-credentials.json
  # Copy the output and save to a local file

Option 4: Using secure file transfer with nc (netcat):
  # On local computer (receiving):
  nc -l 9999 > ai-launchkit-credentials.json
  
  # On VPS (sending):
  nc your-local-ip 9999 < ~/ai-launchkit/ai-launchkit-credentials.json

HOW TO IMPORT INTO VAULTWARDEN:
--------------------------------

1. Open Vaultwarden: https://your-vault-domain
2. Login to your account
3. Go to: Tools → Import Data
4. Select Format: "Bitwarden (json)"
5. Choose File: ai-launchkit-credentials.json
6. Click: Import Data

All credentials will be imported into the "AI LaunchKit Services" folder.

SECURITY NOTES:
---------------
⚠️  DELETE the JSON file from both VPS and local computer after import!
⚠️  This file contains ALL your passwords in plain text!

To delete:
  # On VPS:
  rm ~/ai-launchkit/ai-launchkit-credentials.json
  
  # On local computer:
  rm ./ai-launchkit-credentials.json
EOF

    log_success "✅ Vaultwarden import file generated: $json_file"
    echo
    log_info "📋 Import Instructions saved to: VAULTWARDEN_IMPORT.txt"
    echo
    echo "🚀 EASY DOWNLOAD:"
    echo "    Run this command for automatic secure download:"
    echo
    echo "    bash ~/ai-launchkit/scripts/download_credentials.sh"
    echo
    echo "    This will:"
    echo "    • Open a temporary web server (60 seconds)"
    echo "    • Show you a download link"
    echo "    • Automatically delete the file after download"
    echo
    echo "📝 MANUAL DOWNLOAD (if needed):"
    echo "    scp $(whoami)@${USER_DOMAIN_NAME}:~/ai-launchkit/ai-launchkit-credentials.json ./"
    echo
    echo "⚠️  SECURITY: The JSON file contains ALL passwords in plain text!"
    echo "    The download script automatically deletes it after 60 seconds."
    echo
    
    return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Load COMPOSE_PROFILES from .env
    if [ -f "$ENV_FILE" ]; then
        COMPOSE_PROFILES=$(grep "^COMPOSE_PROFILES=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"')
        export COMPOSE_PROFILES
    fi
    
    generate_vaultwarden_json
fi
