#!/bin/bash

set -e

# Source the utilities file
source "$(dirname "$0")/utils.sh"

# Check for openssl
if ! command -v openssl &> /dev/null; then
    log_error "openssl could not be found. Please ensure it is installed and available in your PATH." >&2
    exit 1
fi

# --- Configuration ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"
TEMPLATE_FILE="$PROJECT_ROOT/.env.example"
OUTPUT_FILE="$PROJECT_ROOT/.env"
ENV_FILE="$OUTPUT_FILE"
DOMAIN_PLACEHOLDER="yourdomain.com"

# Variables to generate: varName="type:length"
# Types: password (alphanum), secret (base64), hex, base64, alphanum
declare -A VARS_TO_GENERATE=(
    ["FLOWISE_PASSWORD"]="password:32"
    ["BOLT_PASSWORD"]="password:32"
    ["N8N_ENCRYPTION_KEY"]="secret:64" # base64 encoded, 48 bytes -> 64 chars
    ["N8N_USER_MANAGEMENT_JWT_SECRET"]="secret:64" # base64 encoded, 48 bytes -> 64 chars
    ["POSTGRES_PASSWORD"]="password:32"
    ["POSTGRES_NON_ROOT_PASSWORD"]="password:32"
    ["JWT_SECRET"]="base64:64" # 48 bytes -> 64 chars
    ["DASHBOARD_PASSWORD"]="password:32" # Supabase Dashboard
    ["CLICKHOUSE_PASSWORD"]="password:32"
    ["MINIO_ROOT_PASSWORD"]="password:32"
    ["LANGFUSE_SALT"]="secret:64" # base64 encoded, 48 bytes -> 64 chars
    ["NEXTAUTH_SECRET"]="secret:64" # base64 encoded, 48 bytes -> 64 chars
    ["ENCRYPTION_KEY"]="hex:64" # Langfuse Encryption Key (32 bytes -> 64 hex chars)
    ["GRAFANA_ADMIN_PASSWORD"]="password:32"
    # From MD file (ensure they are in template if needed)
    ["SECRET_KEY_BASE"]="base64:64" # 48 bytes -> 64 chars
    ["VAULT_ENC_KEY"]="alphanum:32"
    ["LOGFLARE_PRIVATE_ACCESS_TOKEN"]="fixed:not-in-use" # For supabase-vector, can't be empty
    ["LOGFLARE_PUBLIC_ACCESS_TOKEN"]="fixed:not-in-use" # For supabase-vector, can't be empty
    ["PROMETHEUS_PASSWORD"]="password:32" # Added Prometheus password
    ["SEARXNG_PASSWORD"]="password:32" # Added SearXNG admin password
    ["LETTA_SERVER_PASSWORD"]="password:32" # Added Letta server password
    ["LANGFUSE_INIT_USER_PASSWORD"]="password:32"
    ["LANGFUSE_INIT_PROJECT_PUBLIC_KEY"]="langfuse_pk:32"
    ["LANGFUSE_INIT_PROJECT_SECRET_KEY"]="langfuse_sk:32"
    ["WEAVIATE_API_KEY"]="secret:48" # API Key for Weaviate service (36 bytes -> 48 chars base64)
    ["QDRANT_API_KEY"]="secret:48" # API Key for Qdrant service
    ["NEO4J_AUTH_PASSWORD"]="password:32" # Added Neo4j password
    ["NEO4J_AUTH_USERNAME"]="fixed:neo4j" # Added Neo4j username
    # Dify environment variables
    ["DIFY_SECRET_KEY"]="secret:64" # Dify application secret key (maps to SECRET_KEY in Dify)
    ["COMFYUI_PASSWORD"]="password:32" # Added ComfyUI basic auth password
    ["RAGAPP_PASSWORD"]="password:32" # Added RAGApp basic auth password
    ["LIBRETRANSLATE_PASSWORD"]="password:32" # Added LibreTranslate basic auth password
    ["WHISPER_AUTH_PASSWORD"]="password:32" # Added Whisper basic auth password
    ["TTS_AUTH_PASSWORD"]="password:32" # Added TTS basic auth password
    ["EASYOCR_SECRET_KEY"]="apikey:32"
    ["LIGHTRAG_PASSWORD"]="password:32"
    ["LIGHTRAG_TOKEN_SECRET"]="apikey:64"
    ["LIGHTRAG_AUTH_ACCOUNTS"]="special:lightrag_auth"
    ["PERPLEXICA_PASSWORD"]="password:32"
    ["ODOO_DB_PASSWORD"]="password:32"
    ["ODOO_MASTER_PASSWORD"]="password:32"
    ["ODOO_PASSWORD"]="password:32"
    ["TWENTY_CRM_DB_PASSWORD"]="password:32"
    ["TWENTY_CRM_APP_SECRET"]="apikey:64"
    ["ESPOCRM_DB_PASSWORD"]="password:32"
    ["ESPOCRM_DB_ROOT_PASSWORD"]="password:32"
    ["ESPOCRM_ADMIN_PASSWORD"]="password:32"
    ["MAUTIC_DB_PASSWORD"]="password:32"
    ["MAUTIC_DB_ROOT_PASSWORD"]="password:32"
    ["MAUTIC_ADMIN_PASSWORD"]="password:20"
    ["BASEROW_SECRET_KEY"]="secret:64"
    ["NOCODB_ADMIN_PASSWORD"]="password:32"
    ["NOCODB_JWT_SECRET"]="apikey:40"
    ["VIKUNJA_JWT_SECRET"]="apikey:32"
    ["MYSQL_ROOT_PASSWORD"]="password:32"
    ["LEANTIME_DB_PASSWORD"]="password:32"
    ["LEANTIME_SESSION_PASSWORD"]="password:64"
    ["CALCOM_NEXTAUTH_SECRET"]="apikey:32"
    ["CALCOM_ENCRYPTION_KEY"]="apikey:32"
    ["JICOFO_COMPONENT_SECRET"]="password:32"
    ["JICOFO_AUTH_PASSWORD"]="password:32"
    ["JVB_AUTH_PASSWORD"]="password:32"
    ["VAULTWARDEN_ADMIN_TOKEN"]="apikey:64"
    ["KOPIA_UI_PASSWORD"]="password:32"
    ["KOPIA_PASSWORD"]="password:32"
    ["KIMAI_ADMIN_PASSWORD"]="password:32"
    ["KIMAI_DB_PASSWORD"]="password:32"
    ["KIMAI_DB_ROOT_PASSWORD"]="password:32"
    ["INVOICENINJA_ADMIN_PASSWORD"]="password:32"
    ["INVOICENINJA_DB_PASSWORD"]="password:32"
    ["INVOICENINJA_DB_ROOT_PASSWORD"]="password:32"
    ["FORMBRICKS_NEXTAUTH_SECRET"]="apikey:32"
    ["FORMBRICKS_ENCRYPTION_KEY"]="apikey:32"
    ["FORMBRICKS_CRON_SECRET"]="apikey:32"
    ["FORMBRICKS_DB_PASSWORD"]="password:32"
    ["METABASE_ENCRYPTION_KEY"]="apikey:32"
    ["METABASE_DB_PASSWORD"]="password:32"
    ["CHATTERBOX_API_KEY"]="apikey:32"
    ["LLM_GUARD_TOKEN"]="apikey:32"
    ["LIVEKIT_API_KEY"]="apikey:32"
    ["LIVEKIT_API_SECRET"]="apikey:32"
    ["VEXA_API_KEY"]="apikey:32"
    ["VEXA_ADMIN_TOKEN"]="apikey:32"
    ["BROWSERLESS_TOKEN"]="apikey:32"
    ["SKYVERN_API_KEY"]="apikey:32"
    ["N8N_MCP_TOKEN"]="apikey:32"
    ["N8N_API_KEY"]="apikey:32"
    ["GPTR_PASSWORD"]="password:32"
    ["SEAFILE_DB_ROOT_PASSWORD"]="password:32"
    ["SEAFILE_DB_PASSWORD"]="password:32"
    ["SEAFILE_ADMIN_PASSWORD"]="password:16"
    ["PAPERLESS_DB_PASSWORD"]="password:32"
    ["PAPERLESS_SECRET_KEY"]="password:64"
    ["PAPERLESS_ADMIN_PASSWORD"]="password:16"
    ["PAPERLESS_GPT_PASSWORD"]="password:32"
    ["LDR_PASSWORD"]="password:32"
    ["OPENNOTEBOOK_PASSWORD"]="password:32"
    ["N8N_RUNNERS_AUTH_TOKEN"]="secret:64"
    ["WEBHOOK_TESTER_PASSWORD"]="password:32"
    ["HOPPSCOTCH_DB_PASSWORD"]="password:32"
    ["HOPPSCOTCH_JWT_SECRET"]="secret:64"
    ["HOPPSCOTCH_SESSION_SECRET"]="secret:64"
    ["HOPPSCOTCH_REFRESH_TOKEN_SECRET"]="secret:64"
    ["HOPPSCOTCH_DATA_ENCRYPTION_KEY"]="alphanum:32"
    ["AIRBYTE_PASSWORD"]="password:32"
    ["AIRBYTE_DESTINATION_DB_PASSWORD"]="password:32"
    ["OUTLINE_SECRET_KEY"]="hex:32"
    ["OUTLINE_UTILS_SECRET"]="hex:32"
    ["OUTLINE_MINIO_ROOT_PASSWORD"]="password:32"
    ["OUTLINE_OIDC_CLIENT_SECRET"]="apikey:32"
    ["DEX_ADMIN_PASSWORD"]="password:20"
    ["DOCUSEAL_DB_PASSWORD"]="password:32"
    ["CODESERVER_PASSWORD"]="password:32"
    ["CODESERVER_SUDO_PASSWORD"]="password:32"
    ["MAILPIT_PASSWORD"]="password:32"
    ["SMTP_PASS"]="password:16"
    ["MAIL_NOREPLY_PASSWORD"]="password:32"
)

# Initialize existing_env_vars and attempt to read .env if it exists
log_info "Initializing environment configuration..."
declare -A existing_env_vars
declare -A generated_values

if [ -f "$OUTPUT_FILE" ]; then
    log_info "Found existing $OUTPUT_FILE. Reading its values to use as defaults and preserve current settings."
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ -n "$line" && ! "$line" =~ ^\s*# && "$line" == *"="* ]]; then
            varName=$(echo "$line" | cut -d'=' -f1 | xargs)
            varValue=$(echo "$line" | cut -d'=' -f2-)
            # Repeatedly unquote "value" or 'value' to get the bare value
            _tempVal="$varValue"
            while true; do
                if [[ "$_tempVal" =~ ^\"(.*)\"$ ]]; then # Check double quotes
                    _tempVal="${BASH_REMATCH[1]}"
                    continue
                fi
                if [[ "$_tempVal" =~ ^\'(.*)\'$ ]]; then # Check single quotes
                    _tempVal="${BASH_REMATCH[1]}"
                    continue
                fi
                break # No more surrounding quotes of these types
            done
            varValue="$_tempVal"
            existing_env_vars["$varName"]="$varValue"
        fi
    done < "$OUTPUT_FILE"
fi

# Install Caddy
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --yes --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt install -y caddy

# Check for caddy
if ! command -v caddy &> /dev/null; then
    log_error "caddy could not be found. Please ensure it is installed and available in your PATH." >&2
    exit 1
fi

# Prompt for the domain name
DOMAIN="" # Initialize DOMAIN variable

# Try to get domain from existing .env file first
# Check if USER_DOMAIN_NAME is set in existing_env_vars and is not empty
if [[ -v existing_env_vars[USER_DOMAIN_NAME] && -n "${existing_env_vars[USER_DOMAIN_NAME]}" ]]; then
    DOMAIN="${existing_env_vars[USER_DOMAIN_NAME]}"
    # Ensure this value is carried over to generated_values for writing and template processing
    # If it came from existing_env_vars, it might already be there, but this ensures it.
    generated_values["USER_DOMAIN_NAME"]="$DOMAIN"
    generated_values["DOMAIN"]="$DOMAIN"  # Also set DOMAIN for services that expect it
else
    while true; do
        echo ""
        prompt_text="Enter the primary domain name for your services (e.g., example.com): " # Simplified prompt
        read -p "$prompt_text" DOMAIN_INPUT

        DOMAIN_TO_USE="$DOMAIN_INPUT" # Direct assignment, no default fallback

        # Validate domain input
        if [[ -z "$DOMAIN_TO_USE" ]]; then
            log_error "Domain name cannot be empty. This field is mandatory." >&2 # Clarified error
            continue # Ask again
        fi

        # Basic check for likely invalid domain characters (very permissive)
        if [[ "$DOMAIN_TO_USE" =~ [^a-zA-Z0-9.-] ]]; then
            log_warning "Warning: Domain name contains potentially invalid characters: '$DOMAIN_TO_USE'" >&2
        fi

        echo ""
        read -p "Are you sure '$DOMAIN_TO_USE' is correct? (y/N): " confirm_domain
        if [[ "$confirm_domain" =~ ^[Yy]$ ]]; then
            DOMAIN="$DOMAIN_TO_USE" # Set the final DOMAIN variable
            generated_values["USER_DOMAIN_NAME"]="$DOMAIN" # Using USER_DOMAIN_NAME
            generated_values["DOMAIN"]="$DOMAIN" # Also set DOMAIN for backward compatibility
            log_info "Domain set to '$DOMAIN'. It will be saved in .env."
            break # Confirmed, exit loop
        else
            log_info "Please try entering the domain name again."
            # No default domain suggestion to retry with.
        fi
    done
fi

# Save BASE_DOMAIN for mail configuration detection
generated_values["BASE_DOMAIN"]="$DOMAIN"

# Auto-detect Docker Host Address for JVB (Jitsi)
if [[ -z "${generated_values[JVB_DOCKER_HOST_ADDRESS]}" ]]; then
    # Try to detect public IP
    PUBLIC_IP=$(curl -s -4 ifconfig.me 2>/dev/null || curl -s -4 icanhazip.com 2>/dev/null || echo "")
    if [[ -n "$PUBLIC_IP" ]]; then
        generated_values["JVB_DOCKER_HOST_ADDRESS"]="$PUBLIC_IP"
        log_info "Auto-detected JVB Docker Host Address: $PUBLIC_IP"
    fi
fi

# Auto-configure Jitsi variables (will be used if Jitsi is selected later)
# Check if Jitsi was previously selected (for re-runs)
if [[ "${existing_env_vars[COMPOSE_PROFILES]}" == *"jitsi"* ]]; then
    JITSI_HOSTNAME="${existing_env_vars[JITSI_HOSTNAME]:-meet.$DOMAIN}"
    generated_values["PUBLIC_URL"]="https://$JITSI_HOSTNAME"
    generated_values["ENABLE_XMPP_WEBSOCKET"]="true"
    generated_values["XMPP_DOMAIN"]="meet.jitsi"
    generated_values["XMPP_SERVER"]="jitsi-prosody"
    log_info "Jitsi variables configured (from previous installation)"
fi

# Prompt for user email
if [[ -z "${existing_env_vars[LETSENCRYPT_EMAIL]}" ]]; then
    echo ""
    echo "Please enter your email address. This email will be used for:"
    echo "   - Login to Flowise"
    echo "   - Login to Supabase"
    echo "   - Login to SearXNG"
    echo "   - Login to Grafana"
    echo "   - Login to Prometheus"
    echo "   - SSL certificate generation with Let\'s Encrypt"
fi

if [[ -n "${existing_env_vars[LETSENCRYPT_EMAIL]}" ]]; then
    USER_EMAIL="${existing_env_vars[LETSENCRYPT_EMAIL]}"
else
    while true; do
        echo ""
        read -p "Email: " USER_EMAIL

        # Validate email input
        if [[ -z "$USER_EMAIL" ]]; then
            log_error "Email cannot be empty." >&2
            continue # Ask again
        fi

        # Basic email format validation
        if [[ ! "$USER_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            log_warning "Warning: Email format appears to be invalid: '$USER_EMAIL'" >&2
        fi

        echo ""
        read -p "Are you sure '$USER_EMAIL' is correct? (y/N): " confirm_email
        if [[ "$confirm_email" =~ ^[Yy]$ ]]; then
            break # Confirmed, exit loop
        else
            log_info "Please try entering the email address again."
        fi
    done
fi

# Prompt for OpenAI API key (optional)
if [[ ! -v existing_env_vars[OPENAI_API_KEY] || -z "${existing_env_vars[OPENAI_API_KEY]}" ]]; then
    echo ""
    echo "OpenAI API Key (optional). This key will be used for:"
    echo "   - Supabase: AI services to help with writing SQL queries, statements, and policies"
    echo "   - Crawl4AI: Default LLM configuration for web crawling capabilities"
    echo "   You can skip this by leaving it empty."
fi

if [[ -v existing_env_vars[OPENAI_API_KEY] ]]; then # -v checks if variable is set (even if empty)
    OPENAI_API_KEY="${existing_env_vars[OPENAI_API_KEY]}"
    if [[ -n "$OPENAI_API_KEY" ]]; then : # Fix: Add null command for empty 'then' block
    else
      log_info "Found empty OpenAI API Key in .env. You can provide one now or leave empty."
      echo ""
      read -p "OpenAI API Key: " OPENAI_API_KEY # Allow update if it was empty
    fi
else
    echo ""
    read -p "OpenAI API Key: " OPENAI_API_KEY
fi

# Prompt for Anthropic API key (optional)
if [[ ! -v existing_env_vars[ANTHROPIC_API_KEY] || -z "${existing_env_vars[ANTHROPIC_API_KEY]}" ]]; then
    echo ""
    echo "Anthropic API Key (optional). This key will be used for:"
    echo "   - bolt.diy: Claude AI models for web development"
    echo "   You can skip this by leaving it empty."
fi

if [[ -v existing_env_vars[ANTHROPIC_API_KEY] ]]; then
    ANTHROPIC_API_KEY="${existing_env_vars[ANTHROPIC_API_KEY]}"
    if [[ -n "$ANTHROPIC_API_KEY" ]]; then :
    else
      log_info "Found empty Anthropic API Key in .env. You can provide one now or leave empty."
      echo ""
      read -p "Anthropic API Key: " ANTHROPIC_API_KEY
    fi
else
    echo ""
    read -p "Anthropic API Key: " ANTHROPIC_API_KEY
fi

# Prompt for Groq API key (optional)
if [[ ! -v existing_env_vars[GROQ_API_KEY] || -z "${existing_env_vars[GROQ_API_KEY]}" ]]; then
    echo ""
    echo "Groq API Key (optional). This key will be used for:"
    echo "   - bolt.diy: Fast inference with Groq's LLM models"
    echo "   You can skip this by leaving it empty."
fi

if [[ -v existing_env_vars[GROQ_API_KEY] ]]; then
    GROQ_API_KEY="${existing_env_vars[GROQ_API_KEY]}"
    if [[ -n "$GROQ_API_KEY" ]]; then :
    else
      log_info "Found empty Groq API Key in .env. You can provide one now or leave empty."
      echo ""
      read -p "Groq API Key: " GROQ_API_KEY
    fi
else
    echo ""
    read -p "Groq API Key: " GROQ_API_KEY
fi

# Logic for n8n workflow import (RUN_N8N_IMPORT)
echo ""

final_run_n8n_import_decision="false"

echo "Do you want to import 300 ready-made workflows for n8n? This process may take about 30 minutes to complete."
echo ""
read -p "Import workflows? (y/n): " import_workflow_choice

if [[ "$import_workflow_choice" =~ ^[Yy]$ ]]; then
    final_run_n8n_import_decision="true"
else
    final_run_n8n_import_decision="false"
fi

# Prompt for number of n8n workers
echo "" # Add a newline for better formatting
log_info "Configuring n8n worker count..."
if [[ -n "${existing_env_vars[N8N_WORKER_COUNT]}" ]]; then
    N8N_WORKER_COUNT_CURRENT="${existing_env_vars[N8N_WORKER_COUNT]}"
    echo ""
    read -p "Do you want to change the number of n8n workers? Current: $N8N_WORKER_COUNT_CURRENT. (Enter new number, or press Enter to keep current): " N8N_WORKER_COUNT_INPUT_RAW
    if [[ -z "$N8N_WORKER_COUNT_INPUT_RAW" ]]; then
        N8N_WORKER_COUNT="$N8N_WORKER_COUNT_CURRENT"
    else
        # Validate the new input
        if [[ "$N8N_WORKER_COUNT_INPUT_RAW" =~ ^0*[1-9][0-9]*$ ]]; then
            N8N_WORKER_COUNT_TEMP="$((10#$N8N_WORKER_COUNT_INPUT_RAW))" # Sanitize (e.g. 01 -> 1)
            if [[ "$N8N_WORKER_COUNT_TEMP" -ge 1 ]]; then
                 echo ""
                 read -p "Update n8n workers to $N8N_WORKER_COUNT_TEMP? (y/N): " confirm_change
                 if [[ "$confirm_change" =~ ^[Yy]$ ]]; then
                    N8N_WORKER_COUNT="$N8N_WORKER_COUNT_TEMP"
                 else
                    N8N_WORKER_COUNT="$N8N_WORKER_COUNT_CURRENT"
                    log_info "Change declined. Keeping N8N_WORKER_COUNT at $N8N_WORKER_COUNT."
                 fi
            else # Should not happen with regex but as a safeguard
                log_warning "Invalid input '$N8N_WORKER_COUNT_INPUT_RAW'. Number must be positive. Keeping $N8N_WORKER_COUNT_CURRENT."
                N8N_WORKER_COUNT="$N8N_WORKER_COUNT_CURRENT"
            fi
        else
            log_warning "Invalid input '$N8N_WORKER_COUNT_INPUT_RAW'. Please enter a positive integer. Keeping $N8N_WORKER_COUNT_CURRENT."
            N8N_WORKER_COUNT="$N8N_WORKER_COUNT_CURRENT"
        fi
    fi
else
    while true; do
        echo ""
        read -p "Enter the number of n8n workers to run (e.g., 1, 2, 3; default is 1): " N8N_WORKER_COUNT_INPUT_RAW
        N8N_WORKER_COUNT_CANDIDATE="${N8N_WORKER_COUNT_INPUT_RAW:-1}" # Default to 1 if empty

        if [[ "$N8N_WORKER_COUNT_CANDIDATE" =~ ^0*[1-9][0-9]*$ ]]; then
            N8N_WORKER_COUNT_VALIDATED="$((10#$N8N_WORKER_COUNT_CANDIDATE))"
            if [[ "$N8N_WORKER_COUNT_VALIDATED" -ge 1 ]]; then
                echo ""
                read -p "Run $N8N_WORKER_COUNT_VALIDATED n8n worker(s)? (y/N): " confirm_workers
                if [[ "$confirm_workers" =~ ^[Yy]$ ]]; then
                    N8N_WORKER_COUNT="$N8N_WORKER_COUNT_VALIDATED"
                    break
                else
                    log_info "Please try entering the number of workers again."
                fi
            else # Should not be reached if regex is correct
                log_error "Number of workers must be a positive integer." >&2
            fi
        else
            log_error "Invalid input '$N8N_WORKER_COUNT_CANDIDATE'. Please enter a positive integer (e.g., 1, 2)." >&2
        fi
    done
fi
# Ensure N8N_WORKER_COUNT is definitely set (should be by logic above)
N8N_WORKER_COUNT="${N8N_WORKER_COUNT:-1}"

log_info "Generating secrets and creating .env file..."

# --- Helper Functions ---
# Usage: gen_random <length> <characters>
gen_random() {
    local length="$1"
    local characters="$2"
    head /dev/urandom | tr -dc "$characters" | head -c "$length"
}

# Usage: gen_password <length>
gen_password() {
    gen_random "$1" 'A-Za-z0-9'
}

# Usage: gen_hex <length> (length = number of hex characters)
gen_hex() {
    local length="$1"
    local bytes=$(( (length + 1) / 2 )) # Calculate bytes needed
    openssl rand -hex "$bytes" | head -c "$length"
}

# Usage: gen_base64 <length> (length = number of base64 characters)
gen_base64() {
    local length="$1"
    # Estimate bytes needed: base64 encodes 3 bytes to 4 chars.
    # So, we need length * 3 / 4 bytes. Use ceil division.
    local bytes=$(( (length * 3 + 3) / 4 ))
    openssl rand -base64 "$bytes" | head -c "$length" # Truncate just in case
}

# Generate hex string (for Outline - needs 32 bytes = 64 hex chars)
gen_hex() {
    local bytes=$1
    openssl rand -hex "$bytes"
}

# Function to update or add a variable to the .env file
# Usage: _update_or_add_env_var "VAR_NAME" "var_value"
_update_or_add_env_var() {
    local var_name="$1"
    local var_value="$2"
    local tmp_env_file

    tmp_env_file=$(mktemp)
    # Ensure temp file is cleaned up if this function exits unexpectedly (though trap in main script should also cover)
    # trap 'rm -f "$tmp_env_file"' EXIT

    if [[ -f "$OUTPUT_FILE" ]]; then
        grep -v -E "^${var_name}=" "$OUTPUT_FILE" > "$tmp_env_file" || true # Allow grep to not find anything
    else
        touch "$tmp_env_file" # Create empty temp if output file doesn't exist yet
    fi

    if [[ -n "$var_value" ]]; then
        echo "${var_name}='$var_value'" >> "$tmp_env_file"
    fi
    mv "$tmp_env_file" "$OUTPUT_FILE"
    # trap - EXIT # Remove specific trap for this temp file if desired, or let main script's trap handle it.
}

# Function to generate a hash using Caddy
# Usage: local HASH=$(_generate_and_get_hash "$plain_password")
_generate_and_get_hash() {
    local plain_password="$1"
    local new_hash=""
    if [[ -n "$plain_password" ]]; then
        new_hash=$(caddy hash-password --algorithm bcrypt --plaintext "$plain_password" 2>/dev/null)
        if [[ $? -ne 0 || -z "$new_hash" ]]; then
            # Optionally, log a warning here if logging was re-enabled
            # echo "Warning: Failed to hash password for use with $1 (placeholder)" >&2
            new_hash="" # Ensure it's empty on failure
        fi
    fi
    echo "$new_hash"
}

# ============================================================================
# MAIL CONFIGURATION DETECTION
# ============================================================================
detect_and_configure_mail() {
    echo
    echo "📧 Configuring Mail System..."
    echo "=========================================="

    # Get BASE_DOMAIN from generated_values
    BASE_DOMAIN="${generated_values[BASE_DOMAIN]}"

    if [[ -z "$BASE_DOMAIN" ]]; then
        echo "⚠️  BASE_DOMAIN not set - using default mail configuration"
        MAIL_MODE="mailpit"
        SMTP_HOST="mailpit"
        SMTP_PORT="1025"
        SMTP_FROM="noreply@local"
        SMTP_SECURE="false"
    elif [[ "$BASE_DOMAIN" == *"sslip.io" ]] || [[ "$BASE_DOMAIN" == *"nip.io" ]] || [[ "$BASE_DOMAIN" == *"localhost"* ]]; then
        echo "🔍 Detected development domain: $BASE_DOMAIN"
        echo "📬 Mailpit will be used for mail capture (no external mail delivery)"
        MAIL_MODE="mailpit"
        SMTP_HOST="mailpit"
        SMTP_PORT="1025"
        SMTP_FROM="noreply@local"
        SMTP_SECURE="false"
    else
        echo "🔍 Detected production domain: $BASE_DOMAIN"
        echo "📬 Default: Mailpit for mail capture"
        echo "💡 Tip: Select 'Docker-Mailserver' in the wizard for real mail delivery"
        MAIL_MODE="mailpit"
        SMTP_HOST="mailpit"
        SMTP_PORT="1025"
        SMTP_FROM="noreply@${BASE_DOMAIN}"
        SMTP_SECURE="false"
    fi

    # Store mail configuration
    generated_values["MAIL_MODE"]="$MAIL_MODE"
    generated_values["SMTP_HOST"]="${SMTP_HOST:-mailpit}"
    generated_values["SMTP_PORT"]="${SMTP_PORT:-1025}"
    generated_values["SMTP_FROM"]="${SMTP_FROM:-noreply@local}"
    generated_values["SMTP_SECURE"]="${SMTP_SECURE:-false}"
    generated_values["SMTP_USER"]="admin"
    generated_values["SMTP_PASS"]="admin"

    echo "✅ Mail configuration completed"
    echo
}

# Force EMAIL_* variables to always mirror SMTP_* for compatibility
# This ensures services like Baserow and CalCom always use the current mail configuration
force_update_email_variables() {
    # Always update EMAIL_* to match current SMTP_* values
    _update_or_add_env_var "EMAIL_FROM" "${generated_values[SMTP_FROM]:-noreply@local}"
    _update_or_add_env_var "EMAIL_SMTP" "${generated_values[SMTP_HOST]:-mailpit}"
    _update_or_add_env_var "EMAIL_SMTP_HOST" "${generated_values[SMTP_HOST]:-mailpit}"
    _update_or_add_env_var "EMAIL_SMTP_PORT" "${generated_values[SMTP_PORT]:-1025}"
    _update_or_add_env_var "EMAIL_SMTP_USER" "${generated_values[SMTP_USER]:-admin}"
    _update_or_add_env_var "EMAIL_SMTP_PASSWORD" "${generated_values[SMTP_PASS]:-admin}"
    _update_or_add_env_var "EMAIL_SMTP_USE_TLS" "${generated_values[SMTP_SECURE]:-false}"

    # CalCom EMAIL_SERVER_* variables (other prefix, same values)
    _update_or_add_env_var "EMAIL_SERVER_HOST" "${generated_values[SMTP_HOST]:-mailpit}"
    _update_or_add_env_var "EMAIL_SERVER_PORT" "${generated_values[SMTP_PORT]:-1025}"
    _update_or_add_env_var "EMAIL_SERVER_USER" "${generated_values[SMTP_USER]:-admin}"
    _update_or_add_env_var "EMAIL_SERVER_PASSWORD" "${generated_values[SMTP_PASS]:-admin}"
}

# --- Main Logic ---

if [ ! -f "$TEMPLATE_FILE" ]; then
    log_error "Template file not found at $TEMPLATE_FILE" >&2
    exit 1
fi

# Pre-populate generated_values with non-empty values from existing_env_vars
for key_from_existing in "${!existing_env_vars[@]}"; do
    if [[ -n "${existing_env_vars[$key_from_existing]}" ]]; then
        generated_values["$key_from_existing"]="${existing_env_vars[$key_from_existing]}"
    fi
done

# Generate missing variables from VARS_TO_GENERATE
for varName in "${!VARS_TO_GENERATE[@]}"; do
    # Skip if already has a value
    if [[ -n "${generated_values[$varName]}" ]]; then
        continue
    fi

    IFS=':' read -r type length <<< "${VARS_TO_GENERATE[$varName]}"
    newValue=""
    case "$type" in
        password|alphanum) newValue=$(gen_password "$length") ;;
        secret|base64) newValue=$(gen_base64 "$length") ;;
        hex) newValue=$(gen_hex "$length") ;;
        apikey) newValue=$(gen_hex "$length") ;;
        langfuse_pk) newValue="pk-lf-$(gen_hex "$length")" ;;
        langfuse_sk) newValue="sk-lf-$(gen_hex "$length")" ;;
        fixed) newValue="$length" ;;
        special)
            if [[ "$varName" == "LIGHTRAG_AUTH_ACCOUNTS" && "$length" == "lightrag_auth" ]]; then
                ADMIN_PASS=$(gen_password 16)
                newValue="admin:${ADMIN_PASS}"
            fi
            ;;
        *) log_warning "Unknown generation type '$type' for $varName" ;;
    esac

    if [[ -n "$newValue" ]]; then
        generated_values["$varName"]="$newValue"
    fi
done

# Configure mail system
detect_and_configure_mail

# Set EMAIL_* variables for services like Baserow that expect different names
# These mirror the SMTP_* settings for compatibility
generated_values["EMAIL_FROM"]="${generated_values[SMTP_FROM]}"
generated_values["EMAIL_SMTP"]="${generated_values[SMTP_HOST]}"
generated_values["EMAIL_SMTP_HOST"]="${generated_values[SMTP_HOST]}"
generated_values["EMAIL_SMTP_PORT"]="${generated_values[SMTP_PORT]}"
generated_values["EMAIL_SMTP_USER"]="${generated_values[SMTP_USER]}"
generated_values["EMAIL_SMTP_PASSWORD"]="${generated_values[SMTP_PASS]}"
generated_values["EMAIL_SMTP_USE_TLS"]="${generated_values[SMTP_SECURE]}"

# Store user input values (potentially overwriting if user was re-prompted and gave new input)
generated_values["BOLT_USERNAME"]="$USER_EMAIL"
generated_values["FLOWISE_USERNAME"]="$USER_EMAIL"
generated_values["DASHBOARD_USERNAME"]="$USER_EMAIL"
generated_values["LETSENCRYPT_EMAIL"]="$USER_EMAIL"
generated_values["RUN_N8N_IMPORT"]="$final_run_n8n_import_decision"
generated_values["PROMETHEUS_USERNAME"]="$USER_EMAIL"
generated_values["SEARXNG_USERNAME"]="$USER_EMAIL"
generated_values["LANGFUSE_INIT_USER_EMAIL"]="$USER_EMAIL"
generated_values["N8N_WORKER_COUNT"]="$N8N_WORKER_COUNT"
generated_values["WEAVIATE_USERNAME"]="$USER_EMAIL" # Set Weaviate username for Caddy
generated_values["COMFYUI_USERNAME"]="$USER_EMAIL" # Set ComfyUI username for Caddy
generated_values["RAGAPP_USERNAME"]="$USER_EMAIL" # Set RAGApp username for Caddy
generated_values["LIBRETRANSLATE_USERNAME"]="$USER_EMAIL" # Set LibreTranslate username for Caddy
generated_values["WHISPER_AUTH_USER"]="$USER_EMAIL" # Set Whisper username for Caddy
generated_values["TTS_AUTH_USER"]="$USER_EMAIL" # Set TTS username for Caddy
generated_values["LIGHTRAG_USERNAME"]="$USER_EMAIL" # Set LightRAG username for Caddy
generated_values["PERPLEXICA_USERNAME"]="$USER_EMAIL" # Set Perplexica username for Caddy
generated_values["ODOO_USERNAME"]="$USER_EMAIL" #Set Odoo username for Caddy
generated_values["MAUTIC_ADMIN_EMAIL"]="$USER_EMAIL"
generated_values["MAUTIC_DB_USER"]="mautic"
generated_values["BASEROW_USERNAME"]="$USER_EMAIL" # Set Baserow username for Caddy
generated_values["KOPIA_UI_USERNAME"]="admin"  # Kopia uses 'admin' by default
generated_values["KIMAI_ADMIN_EMAIL"]="$USER_EMAIL"
generated_values["INVOICENINJA_ADMIN_EMAIL"]="$USER_EMAIL"
generated_values["GPTR_USERNAME"]="$USER_EMAIL"
generated_values["SEAFILE_ADMIN_EMAIL"]="$USER_EMAIL"
generated_values["PAPERLESS_ADMIN_EMAIL"]="$USER_EMAIL"
generated_values["PAPERLESS_GPT_USERNAME"]="$USER_EMAIL"
generated_values["WEBHOOK_TESTER_USERNAME"]="$USER_EMAIL"
generated_values["AIRBYTE_USERNAME"]="admin"  # Airbyte uses fixed admin username
generated_values["MAILPIT_USERNAME"]="$USER_EMAIL"  # Set Mailpit username for Caddy

if [[ -n "$OPENAI_API_KEY" ]]; then
    generated_values["OPENAI_API_KEY"]="$OPENAI_API_KEY"
fi

if [[ -n "$ANTHROPIC_API_KEY" ]]; then
    generated_values["ANTHROPIC_API_KEY"]="$ANTHROPIC_API_KEY"
fi

if [[ -n "$GROQ_API_KEY" ]]; then
    generated_values["GROQ_API_KEY"]="$GROQ_API_KEY"
fi

# Set mail service hostnames
BASE_DOMAIN="${generated_values[BASE_DOMAIN]}"
if [[ -n "$BASE_DOMAIN" ]]; then
    # Mailpit hostname (if not already set)
    if [[ -z "${generated_values[MAILPIT_HOSTNAME]}" ]]; then
        generated_values["MAILPIT_HOSTNAME"]="mail.${BASE_DOMAIN}"
    fi
    
    # Chatterbox TTS hostnames (if not already set)
    if [[ -z "${generated_values[CHATTERBOX_HOSTNAME]}" ]]; then
        generated_values["CHATTERBOX_HOSTNAME"]="chatterbox.${BASE_DOMAIN}"
    fi
    if [[ -z "${generated_values[CHATTERBOX_FRONTEND_HOSTNAME]}" ]]; then
        generated_values["CHATTERBOX_FRONTEND_HOSTNAME"]="voice.${BASE_DOMAIN}"
    fi
fi

# Create website directory and default landing page
if [ ! -d "./website" ]; then
    log_info "Creating website directory for landing page..."
    mkdir -p ./website
fi

if [ ! -f "./website/index.html" ]; then
    log_info "Creating default landing page..."
    if [ -f "./templates/landing-page.html" ]; then
        cp ./templates/landing-page.html ./website/index.html
        log_success "Landing page installed at main domain"
    else
        log_warning "Landing page template not found in ./templates/"
    fi
fi

# Create a temporary file for processing
TMP_ENV_FILE=$(mktemp)
# Ensure temp file is cleaned up on exit
trap 'rm -f "$TMP_ENV_FILE"' EXIT

# Track whether our custom variables were found in the template
declare -A found_vars
found_vars["FLOWISE_USERNAME"]=0
found_vars["DASHBOARD_USERNAME"]=0
found_vars["LETSENCRYPT_EMAIL"]=0
found_vars["RUN_N8N_IMPORT"]=0
found_vars["PROMETHEUS_USERNAME"]=0
found_vars["SEARXNG_USERNAME"]=0
found_vars["OPENAI_API_KEY"]=0
found_vars["ANTHROPIC_API_KEY"]=0
found_vars["GROQ_API_KEY"]=0
found_vars["LANGFUSE_INIT_USER_EMAIL"]=0
found_vars["N8N_WORKER_COUNT"]=0
found_vars["WEAVIATE_USERNAME"]=0
found_vars["NEO4J_AUTH_USERNAME"]=0
found_vars["COMFYUI_USERNAME"]=0
found_vars["RAGAPP_USERNAME"]=0
found_vars["LIBRETRANSLATE_USERNAME"]=0
found_vars["WHISPER_AUTH_USER"]=0
found_vars["TTS_AUTH_USER"]=0
found_vars["LIGHTRAG_USERNAME"]=0
found_vars["PERPLEXICA_USERNAME"]=0
found_vars["ODOO_USERNAME"]=0
found_vars["MAUTIC_ADMIN_EMAIL"]=0
found_vars["MAUTIC_DB_USER"]=0
found_vars["BASEROW_USERNAME"]=0
found_vars["KOPIA_UI_USERNAME"]=0
found_vars["KIMAI_ADMIN_EMAIL"]=0
found_vars["INVOICENINJA_ADMIN_EMAIL"]=0
found_vars["GPTR_USERNAME"]=0
found_vars["WEBHOOK_TESTER_USERNAME"]=0
found_vars["PAPERLESS_GPT_USERNAME"]=0
found_vars["PAPERLESS_AI_HOSTNAME"]=0
found_vars["OUTLINE_MINIO_ROOT_USER"]=0
found_vars["DEX_ADMIN_EMAIL"]=0
found_vars["DEX_ADMIN_PASSWORD_HASH"]=0
found_vars["MAILPIT_USERNAME"]=0
found_vars["EMAIL_FROM"]=0
found_vars["EMAIL_SMTP"]=0
found_vars["EMAIL_SMTP_HOST"]=0
found_vars["EMAIL_SMTP_PORT"]=0
found_vars["EMAIL_SMTP_USER"]=0
found_vars["EMAIL_SMTP_PASSWORD"]=0
found_vars["EMAIL_SMTP_USE_TLS"]=0
found_vars["DOMAIN"]=0  # Add DOMAIN to track if it's in template

# Read template, substitute domain, generate initial values
while IFS= read -r line || [[ -n "$line" ]]; do
    # Substitute domain placeholder
    processed_line=$(echo "$line" | sed "s/$DOMAIN_PLACEHOLDER/$DOMAIN/g")

    # Check if it's a variable assignment line (non-empty, not comment, contains '=')
    if [[ -n "$processed_line" && ! "$processed_line" =~ ^\s*# && "$processed_line" == *"="* ]]; then
        varName=$(echo "$processed_line" | cut -d'=' -f1 | xargs) # Trim whitespace
        currentValue=$(echo "$processed_line" | cut -d'=' -f2-)

        # If already have a non-empty value from existing .env or prior generation/user input, use it
        if [[ -n "${generated_values[$varName]}" ]]; then
            processed_line="${varName}=\"${generated_values[$varName]}\""
        # Check if this is one of our user-input derived variables that might not have a value yet
        # (e.g. OPENAI_API_KEY if user left it blank). These are handled by `found_vars` later if needed.
        # Or, if variable needs generation AND is not already populated (or is empty) in generated_values
        elif [[ -v VARS_TO_GENERATE["$varName"] && -z "${generated_values[$varName]}" ]]; then
            IFS=':' read -r type length <<< "${VARS_TO_GENERATE[$varName]}"
            newValue=""
            case "$type" in
                password|alphanum) newValue=$(gen_password "$length") ;;
                secret|base64) newValue=$(gen_base64 "$length") ;;
                hex) newValue=$(gen_hex "$length") ;;
                apikey) newValue=$(gen_hex "$length") ;;
                langfuse_pk) newValue="pk-lf-$(gen_hex "$length")" ;;
                langfuse_sk) newValue="sk-lf-$(gen_hex "$length")" ;;
                fixed) newValue="$length" ;; # Handle fixed type
                special)
                    if [[ "$varName" == "LIGHTRAG_AUTH_ACCOUNTS" && "$length" == "lightrag_auth" ]]; then
                        ADMIN_PASS=$(gen_password 16)
                        newValue="admin:${ADMIN_PASS}"
                    fi
                    ;;
                *) log_warning "Unknown generation type '$type' for $varName" ;;
            esac

            if [[ -n "$newValue" ]]; then
                processed_line="${varName}=\"${newValue}\"" # Quote generated values
                generated_values["$varName"]="$newValue"    # Store newly generated
            else
                # Keep original line structure but ensure value is empty if generation failed
                # but it was in VARS_TO_GENERATE
                processed_line="${varName}=\""
                generated_values["$varName"]="" # Explicitly mark as empty in generated_values
            fi
        # For variables from the template that are not in VARS_TO_GENERATE and not already in generated_values
        # store their template value if it's a direct assignment (not a ${...} substitution)
        # This allows them to be used in later ${VAR} substitutions if they are referenced.
        else
            # This 'else' block is for lines from template not covered by existing values or VARS_TO_GENERATE.
            # Check if it is one of the user input vars - these are handled by found_vars later if not in template.
            is_user_input_var=0 # Reset for each line
            user_input_vars=("FLOWISE_USERNAME" "DASHBOARD_USERNAME" "LETSENCRYPT_EMAIL" "RUN_N8N_IMPORT" "PROMETHEUS_USERNAME" "SEARXNG_USERNAME" "OPENAI_API_KEY" "LANGFUSE_INIT_USER_EMAIL" "N8N_WORKER_COUNT" "WEAVIATE_USERNAME" "NEO4J_AUTH_USERNAME" "COMFYUI_USERNAME" "WEBHOOK_TESTER_USERNAME" "RAGAPP_USERNAME" "LIBRETRANSLATE_USERNAME" "WHISPER_AUTH_USER" "TTS_AUTH_USER" "ODOO_USERNAME" "BASEROW_USERNAME" "KOPIA_UI_USERNAME" "GPTR_USERNAME" "MAILPIT_USERNAME" "MAUTIC_ADMIN_EMAIL" "MAUTIC_DB_USER" "INVOICENINJA_ADMIN_EMAIL" "SEAFILE_ADMIN_EMAIL" "PAPERLESS_ADMIN_EMAIL" "PAPERLESS_GPT_USERNAME" "PAPERLESS_AI_HOSTNAME" "DEX_ADMIN_EMAIL" "DEX_ADMIN_PASSWORD_HASH" "EMAIL_FROM" "EMAIL_SMTP" "EMAIL_SMTP_HOST" "EMAIL_SMTP_PORT" "EMAIL_SMTP_USER" "EMAIL_SMTP_PASSWORD" "EMAIL_SMTP_USE_TLS" "DOMAIN")
            for uivar in "${user_input_vars[@]}"; do
                if [[ "$varName" == "$uivar" ]]; then
                    is_user_input_var=1
                    # Mark as found if it's in template, value taken from generated_values if already set or blank
                    found_vars["$varName"]=1
                    if [[ -v generated_values[$varName] ]]; then # if it was set (even to empty by user)
                        processed_line="${varName}=\"${generated_values[$varName]}\""
                    else # Not set in generated_values, keep template's default if any, or make it empty
                        if [[ "$currentValue" =~ ^\$\{.*\} || -z "$currentValue" ]]; then # if template is ${VAR} or empty
                            processed_line="${varName}=\"\""
                        else # template has a default simple value
                            processed_line="${varName}=\"$currentValue\"" # Use template's default, and quote it
                        fi
                    fi
                    break
                fi
            done

            if [[ $is_user_input_var -eq 0 ]]; then # Not a user input var, not in VARS_TO_GENERATE, not in existing
                trimmed_value=$(echo "$currentValue" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'//")
                if [[ -n "$varName" && -n "$trimmed_value" && "$trimmed_value" != "\${INSTANCE_DOMAIN}" && "$trimmed_value" != "\${SUBDOMAIN_WILDCARD_CERT}" && ! "$trimmed_value" =~ ^\\$\\{ ]]; then # Check for other placeholders
                    # Only store if not already in generated_values and not a placeholder reference
                    if [[ -z "${generated_values[$varName]}" ]]; then
                        generated_values["$varName"]="$trimmed_value"
                    fi
                fi
                # processed_line remains as is (from template, after domain sub) for these cases
            fi
        fi
    fi
    echo "$processed_line" >> "$TMP_ENV_FILE"
done < "$TEMPLATE_FILE"

# Generate placeholder Supabase keys (always generate these)

# Function to create a JWT token
create_jwt() {
    local role=$1
    local jwt_secret=$2
    local now=$(date +%s)
    local exp=$((now + 315360000)) # 10 years from now (seconds)

    # Create header (alg=HS256, typ=JWT)
    local header='{"alg":"HS256","typ":"JWT"}'
    # Create payload with role, issued at time, and expiry
    local payload="{\"role\":\"$role\",\"iss\":\"supabase\",\"iat\":$now,\"exp\":$exp}"

    # Base64url encode header and payload
    local b64_header=$(echo -n "$header" | base64 -w 0 | tr '/+' '_-' | tr -d '=')
    local b64_payload=$(echo -n "$payload" | base64 -w 0 | tr '/+' '_-' | tr -d '=')

    # Create signature
    local signature_input="$b64_header.$b64_payload"
    local signature=$(echo -n "$signature_input" | openssl dgst -sha256 -hmac "$jwt_secret" -binary | base64 -w 0 | tr '/+' '_-' | tr -d '=')

    # Combine to form JWT
    echo -n "$b64_header.$b64_payload.$signature" # Use echo -n to avoid trailing newline
}

# Get JWT secret from previously generated values
JWT_SECRET_TO_USE="${generated_values["JWT_SECRET"]}"

if [[ -z "$JWT_SECRET_TO_USE" ]]; then
    # This should ideally have been generated by VARS_TO_GENERATE if it was missing
    # and JWT_SECRET is in VARS_TO_GENERATE. For safety, generate if truly empty.
    log_warning "JWT_SECRET was empty, attempting to generate it now."
    # Assuming JWT_SECRET definition is 'base64:64'
    JWT_SECRET_TO_USE=$(gen_base64 64)
    generated_values["JWT_SECRET"]="$JWT_SECRET_TO_USE"
fi

# Generate the actual JWT tokens using the JWT_SECRET_TO_USE, if not already set
if [[ -z "${generated_values[ANON_KEY]}" ]]; then
    generated_values["ANON_KEY"]=$(create_jwt "anon" "$JWT_SECRET_TO_USE")
fi

if [[ -z "${generated_values[SERVICE_ROLE_KEY]}" ]]; then
    generated_values["SERVICE_ROLE_KEY"]=$(create_jwt "service_role" "$JWT_SECRET_TO_USE")
fi

# Add any custom variables that weren't found in the template
for var in "FLOWISE_USERNAME" "DASHBOARD_USERNAME" "LETSENCRYPT_EMAIL" "RUN_N8N_IMPORT" "OPENAI_API_KEY" "ANTHROPIC_API_KEY" "GROQ_API_KEY" "PROMETHEUS_USERNAME" "SEARXNG_USERNAME" "LANGFUSE_INIT_USER_EMAIL" "N8N_WORKER_COUNT" "WEAVIATE_USERNAME" "NEO4J_AUTH_USERNAME" "COMFYUI_USERNAME" "RAGAPP_USERNAME" "WHISPER_AUTH_USER" "TTS_AUTH_USER" "LIBRETRANSLATE_USERNAME" "LIGHTRAG_USERNAME" "PERPLEXICA_USERNAME" "WEBHOOK_TESTER_USERNAME" "ODOO_USERNAME" "BASEROW_USERNAME" "KOPIA_UI_USERNAME" "MAILPIT_USERNAME" "GPTR_USERNAME" "MAUTIC_ADMIN_EMAIL" "MAUTIC_DB_USER" "INVOICENINJA_ADMIN_EMAIL" "SEAFILE_ADMIN_EMAIL" "PAPERLESS_ADMIN_EMAIL" "PAPERLESS_GPT_USERNAME" "PAPERLESS_AI_HOSTNAME" "DEX_ADMIN_EMAIL" "DEX_ADMIN_PASSWORD_HASH" "EMAIL_FROM" "EMAIL_SMTP" "EMAIL_SMTP_HOST" "EMAIL_SMTP_PORT" "EMAIL_SMTP_USER" "EMAIL_SMTP_PASSWORD" "EMAIL_SMTP_USE_TLS" "DOMAIN"; do
    if [[ ${found_vars["$var"]} -eq 0 && -v generated_values["$var"] ]]; then
        # Before appending, check if it's already in TMP_ENV_FILE to avoid duplicates
        if ! grep -q -E "^${var}=" "$TMP_ENV_FILE"; then
            echo "${var}=\"${generated_values[$var]}\"" >> "$TMP_ENV_FILE" # Ensure quoting
        fi
    fi
done

# Second pass: Substitute generated values referenced like ${VAR}
# We'll process the substitutions line by line to avoid escaping issues

# Copy the temporary file to the output
cp "$TMP_ENV_FILE" "$OUTPUT_FILE"

log_info "Applying variable substitutions..."

# Process each generated value
for key in "${!generated_values[@]}"; do
    value="${generated_values[$key]}"

    # Create a temporary file for this value to avoid escaping issues
    value_file=$(mktemp)
    echo -n "$value" > "$value_file"

    # Create a new temporary file for the output
    new_output=$(mktemp)

    # Process each line in the file
    while IFS= read -r line; do
        # Replace ${KEY} format
        if [[ "$line" == *"\${$key}"* ]]; then
            placeholder="\${$key}"
            replacement=$(cat "$value_file")
            line="${line//$placeholder/$replacement}"
        fi

        # Replace $KEY format
        if [[ "$line" == *"$"$key* ]]; then
            placeholder="$"$key
            replacement=$(cat "$value_file")
            line="${line//$placeholder/$replacement}"
        fi

        # Handle specific cases
        if [[ "$key" == "ANON_KEY" && "$line" == "ANON_KEY="* ]]; then
            line="ANON_KEY=\"$(cat "$value_file")\""
        fi

        if [[ "$key" == "SERVICE_ROLE_KEY" && "$line" == "SERVICE_ROLE_KEY="* ]]; then
            line="SERVICE_ROLE_KEY=\"$(cat "$value_file")\""
        fi

        if [[ "$key" == "ANON_KEY" && "$line" == "SUPABASE_ANON_KEY="* ]]; then
            line="SUPABASE_ANON_KEY=\"$(cat "$value_file")\""
        fi

        if [[ "$key" == "SERVICE_ROLE_KEY" && "$line" == "SUPABASE_SERVICE_ROLE_KEY="* ]]; then
            line="SUPABASE_SERVICE_ROLE_KEY=\"$(cat "$value_file")\""
        fi

        if [[ "$key" == "JWT_SECRET" && "$line" == "SUPABASE_JWT_SECRET="* ]]; then
            line="SUPABASE_JWT_SECRET=\"$(cat "$value_file")\""
        fi

        if [[ "$key" == "POSTGRES_PASSWORD" && "$line" == "SUPABASE_POSTGRES_PASSWORD="* ]]; then
            line="SUPABASE_POSTGRES_PASSWORD=\"$(cat "$value_file")\""
        fi

        # Write the processed line to the new file
        echo "$line" >> "$new_output"
    done < "$OUTPUT_FILE"

    # Replace the output file with the new version
    mv "$new_output" "$OUTPUT_FILE"

    # Clean up
    rm -f "$value_file"
done

# Hash passwords using caddy with bcrypt
PROMETHEUS_PLAIN_PASS="${generated_values["PROMETHEUS_PASSWORD"]}"
SEARXNG_PLAIN_PASS="${generated_values["SEARXNG_PASSWORD"]}"

# --- PROMETHEUS ---
# Try to get existing hash from memory (populated from .env if it was there)
FINAL_PROMETHEUS_HASH="${generated_values[PROMETHEUS_PASSWORD_HASH]}"

# If no hash in memory, but we have a plain password, generate a new hash
if [[ -z "$FINAL_PROMETHEUS_HASH" && -n "$PROMETHEUS_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$PROMETHEUS_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_PROMETHEUS_HASH="$NEW_HASH"
        generated_values["PROMETHEUS_PASSWORD_HASH"]="$NEW_HASH" # Update memory for consistency
    fi
fi
# Update the .env file with the final determined hash (could be empty if no plain pass or hash failed)
_update_or_add_env_var "PROMETHEUS_PASSWORD_HASH" "$FINAL_PROMETHEUS_HASH"

# --- SEARXNG ---
FINAL_SEARXNG_HASH="${generated_values[SEARXNG_PASSWORD_HASH]}"

if [[ -z "$FINAL_SEARXNG_HASH" && -n "$SEARXNG_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$SEARXNG_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_SEARXNG_HASH="$NEW_HASH"
        generated_values["SEARXNG_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "SEARXNG_PASSWORD_HASH" "$FINAL_SEARXNG_HASH"

# --- COMFYUI ---
COMFYUI_PLAIN_PASS="${generated_values["COMFYUI_PASSWORD"]}"
FINAL_COMFYUI_HASH="${generated_values[COMFYUI_PASSWORD_HASH]}"
if [[ -z "$FINAL_COMFYUI_HASH" && -n "$COMFYUI_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$COMFYUI_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_COMFYUI_HASH="$NEW_HASH"
        generated_values["COMFYUI_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "COMFYUI_PASSWORD_HASH" "$FINAL_COMFYUI_HASH"

# --- BOLT ---
BOLT_PLAIN_PASS="${generated_values["BOLT_PASSWORD"]}"
FINAL_BOLT_HASH="${generated_values[BOLT_PASSWORD_HASH]}"
if [[ -z "$FINAL_BOLT_HASH" && -n "$BOLT_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$BOLT_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_BOLT_HASH="$NEW_HASH"
        generated_values["BOLT_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "BOLT_PASSWORD_HASH" "$FINAL_BOLT_HASH"

# --- WEBHOOK_TESTER ---
WEBHOOK_TESTER_PLAIN_PASS="${generated_values["WEBHOOK_TESTER_PASSWORD"]}"
FINAL_WEBHOOK_TESTER_HASH="${generated_values[WEBHOOK_TESTER_PASSWORD_HASH]}"
if [[ -z "$FINAL_WEBHOOK_TESTER_HASH" && -n "$WEBHOOK_TESTER_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$WEBHOOK_TESTER_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_WEBHOOK_TESTER_HASH="$NEW_HASH"
        generated_values["WEBHOOK_TESTER_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "WEBHOOK_TESTER_PASSWORD_HASH" "$FINAL_WEBHOOK_TESTER_HASH"

# --- RAGAPP ---
RAGAPP_PLAIN_PASS="${generated_values["RAGAPP_PASSWORD"]}"
FINAL_RAGAPP_HASH="${generated_values[RAGAPP_PASSWORD_HASH]}"
if [[ -z "$FINAL_RAGAPP_HASH" && -n "$RAGAPP_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$RAGAPP_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_RAGAPP_HASH="$NEW_HASH"
        generated_values["RAGAPP_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "RAGAPP_PASSWORD_HASH" "$FINAL_RAGAPP_HASH"

# --- LIBRETRANSLATE ---
LIBRETRANSLATE_PLAIN_PASS="${generated_values["LIBRETRANSLATE_PASSWORD"]}"
FINAL_LIBRETRANSLATE_HASH="${generated_values[LIBRETRANSLATE_PASSWORD_HASH]}"
if [[ -z "$FINAL_LIBRETRANSLATE_HASH" && -n "$LIBRETRANSLATE_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$LIBRETRANSLATE_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_LIBRETRANSLATE_HASH="$NEW_HASH"
        generated_values["LIBRETRANSLATE_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "LIBRETRANSLATE_PASSWORD_HASH" "$FINAL_LIBRETRANSLATE_HASH"

# --- WHISPER ---
WHISPER_PLAIN_PASS="${generated_values["WHISPER_AUTH_PASSWORD"]}"
FINAL_WHISPER_HASH="${generated_values[WHISPER_AUTH_PASSWORD_HASH]}"
if [[ -z "$FINAL_WHISPER_HASH" && -n "$WHISPER_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$WHISPER_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_WHISPER_HASH="$NEW_HASH"
        generated_values["WHISPER_AUTH_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "WHISPER_AUTH_PASSWORD_HASH" "$FINAL_WHISPER_HASH"

# --- TTS ---
TTS_PLAIN_PASS="${generated_values["TTS_AUTH_PASSWORD"]}"
FINAL_TTS_HASH="${generated_values[TTS_AUTH_PASSWORD_HASH]}"
if [[ -z "$FINAL_TTS_HASH" && -n "$TTS_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$TTS_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_TTS_HASH="$NEW_HASH"
        generated_values["TTS_AUTH_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "TTS_AUTH_PASSWORD_HASH" "$FINAL_TTS_HASH"

# --- LIGHTRAG ---
LIGHTRAG_PLAIN_PASS="${generated_values["LIGHTRAG_PASSWORD"]}"
FINAL_LIGHTRAG_HASH="${generated_values[LIGHTRAG_PASSWORD_HASH]}"
if [[ -z "$FINAL_LIGHTRAG_HASH" && -n "$LIGHTRAG_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$LIGHTRAG_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_LIGHTRAG_HASH="$NEW_HASH"
        generated_values["LIGHTRAG_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "LIGHTRAG_PASSWORD_HASH" "$FINAL_LIGHTRAG_HASH"

# --- PERPLEXICA ---
PERPLEXICA_PLAIN_PASS="${generated_values["PERPLEXICA_PASSWORD"]}"
FINAL_PERPLEXICA_HASH="${generated_values[PERPLEXICA_PASSWORD_HASH]}"
if [[ -z "$FINAL_PERPLEXICA_HASH" && -n "$PERPLEXICA_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$PERPLEXICA_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_PERPLEXICA_HASH="$NEW_HASH"
        generated_values["PERPLEXICA_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "PERPLEXICA_PASSWORD_HASH" "$FINAL_PERPLEXICA_HASH"

# --- ODOO ---
ODOO_PLAIN_PASS="${generated_values["ODOO_PASSWORD"]}"
FINAL_ODOO_HASH="${generated_values[ODOO_PASSWORD_HASH]}"
if [[ -z "$FINAL_ODOO_HASH" && -n "$ODOO_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$ODOO_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_ODOO_HASH="$NEW_HASH"
        generated_values["ODOO_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "ODOO_PASSWORD_HASH" "$FINAL_ODOO_HASH"

# --- BASEROW ---
BASEROW_PLAIN_PASS="${generated_values["BASEROW_PASSWORD"]}"
FINAL_BASEROW_HASH="${generated_values[BASEROW_PASSWORD_HASH]}"
if [[ -z "$FINAL_BASEROW_HASH" && -n "$BASEROW_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$BASEROW_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_BASEROW_HASH="$NEW_HASH"
        generated_values["BASEROW_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "BASEROW_PASSWORD_HASH" "$FINAL_BASEROW_HASH"

# --- MAILPIT ---
MAILPIT_PLAIN_PASS="${generated_values["MAILPIT_PASSWORD"]}"
FINAL_MAILPIT_HASH="${generated_values[MAILPIT_PASSWORD_HASH]}"
if [[ -z "$FINAL_MAILPIT_HASH" && -n "$MAILPIT_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$MAILPIT_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_MAILPIT_HASH="$NEW_HASH"
        generated_values["MAILPIT_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "MAILPIT_PASSWORD_HASH" "$FINAL_MAILPIT_HASH"

# --- DEX ADMIN PASSWORD HASH ---
# Special handling for Dex admin account
if [[ -z "${generated_values[DEX_ADMIN_EMAIL]}" ]]; then
    generated_values["DEX_ADMIN_EMAIL"]="$USER_EMAIL"
    _update_or_add_env_var "DEX_ADMIN_EMAIL" "$USER_EMAIL"
fi

DEX_ADMIN_PLAIN_PASS="${generated_values["DEX_ADMIN_PASSWORD"]}"
FINAL_DEX_HASH="${generated_values[DEX_ADMIN_PASSWORD_HASH]}"
if [[ -z "$FINAL_DEX_HASH" && -n "$DEX_ADMIN_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$DEX_ADMIN_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_DEX_HASH="$NEW_HASH"
        generated_values["DEX_ADMIN_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "DEX_ADMIN_PASSWORD_HASH" "$FINAL_DEX_HASH"

# --- GPT RESEARCHER ---
GPTR_PLAIN_PASS="${generated_values["GPTR_PASSWORD"]}"
FINAL_GPTR_HASH="${generated_values[GPTR_PASSWORD_HASH]}"
if [[ -z "$FINAL_GPTR_HASH" && -n "$GPTR_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$GPTR_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_GPTR_HASH="$NEW_HASH"
        generated_values["GPTR_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "GPTR_PASSWORD_HASH" "$FINAL_GPTR_HASH"

# --- PAPERLESS-GPT ---
PAPERLESS_GPT_PLAIN_PASS="${generated_values["PAPERLESS_GPT_PASSWORD"]}"
FINAL_PAPERLESS_GPT_HASH="${generated_values[PAPERLESS_GPT_PASSWORD_HASH]}"
if [[ -z "$FINAL_PAPERLESS_GPT_HASH" && -n "$PAPERLESS_GPT_PLAIN_PASS" ]]; then
    NEW_HASH=$(_generate_and_get_hash "$PAPERLESS_GPT_PLAIN_PASS")
    if [[ -n "$NEW_HASH" ]]; then
        FINAL_PAPERLESS_GPT_HASH="$NEW_HASH"
        generated_values["PAPERLESS_GPT_PASSWORD_HASH"]="$NEW_HASH"
    fi
fi
_update_or_add_env_var "PAPERLESS_GPT_PASSWORD_HASH" "$FINAL_PAPERLESS_GPT_HASH"

# --- INVOICE NINJA APP_KEY ---
# Special handling for Invoice Ninja APP_KEY (must be generated with Laravel)
if [[ -z "${generated_values[INVOICENINJA_APP_KEY]}" ]] && [[ -z "${existing_env_vars[INVOICENINJA_APP_KEY]}" ]]; then
    log_info "Generating Invoice Ninja APP_KEY..."
    log_warning "If this fails, manually run:"
    log_warning "docker run --rm invoiceninja/invoiceninja:5 php artisan key:generate --show"
    
    # Try to generate with Docker if available
    if command -v docker &> /dev/null; then
        APP_KEY=$(docker run --rm invoiceninja/invoiceninja:5 php artisan key:generate --show 2>/dev/null | grep "base64:" || true)
        if [[ -n "$APP_KEY" ]]; then
            generated_values["INVOICENINJA_APP_KEY"]="$APP_KEY"
            _update_or_add_env_var "INVOICENINJA_APP_KEY" "$APP_KEY"
            log_success "Invoice Ninja APP_KEY generated successfully"
        else
            log_error "Failed to generate APP_KEY - you must generate it manually before starting Invoice Ninja"
        fi
    else
        log_warning "Docker not available - generate APP_KEY manually before starting"
    fi
fi

# --- METABASE ENCRYPTION KEY ---
# Metabase requires exactly 32 characters for encryption
if [[ -z "${generated_values[METABASE_ENCRYPTION_KEY]}" ]]; then
    log_info "Generating Metabase ENCRYPTION_KEY..."
    # Metabase needs exactly 32 hex characters (16 bytes)
    ENCRYPTION_KEY=$(openssl rand -hex 16)  # 16 bytes = 32 hex chars
    generated_values["METABASE_ENCRYPTION_KEY"]="$ENCRYPTION_KEY"
    _update_or_add_env_var "METABASE_ENCRYPTION_KEY" "$ENCRYPTION_KEY"
fi

# --- N8N TASK RUNNER VERSION ---
# Auto-detect n8n version by pulling image and reading label
log_info "Detecting n8n version for task runners..."

# Pull latest n8n image (will be reused by docker compose build later)
log_info "Pulling n8nio/n8n:latest to detect version..."
if ! docker pull n8nio/n8n:latest > /dev/null 2>&1; then
    log_error "Could not pull n8nio/n8n:latest. Check internet connection."
    exit 1
fi

# Read version from image label
RUNNERS_VERSION=$(docker inspect n8nio/n8n:latest | \
  jq -r '.[0].Config.Labels["org.opencontainers.image.version"]' 2>/dev/null)

if [[ -z "$RUNNERS_VERSION" || "$RUNNERS_VERSION" == "null" ]]; then
    log_error "Could not read version from n8n image label."
    exit 1
fi

log_success "Detected n8n/runners version: $RUNNERS_VERSION"
generated_values["N8N_RUNNERS_VERSION"]="$RUNNERS_VERSION"
_update_or_add_env_var "N8N_RUNNERS_VERSION" "$RUNNERS_VERSION"

# Ensure DOMAIN is written to .env for backward compatibility
if [[ -n "${generated_values[DOMAIN]}" ]]; then
    _update_or_add_env_var "DOMAIN" "${generated_values[DOMAIN]}"
fi

if [ $? -eq 0 ]; then # This $? reflects the status of the last mv command from the last _update_or_add_env_var call.
    # For now, assuming if we reached here and mv was fine, primary operations were okay.
    echo ".env file generated successfully in the project root ($OUTPUT_FILE)."
else
    log_error "Failed to generate .env file." >&2
    rm -f "$OUTPUT_FILE" # Clean up potentially broken output file
    exit 1
fi

# Force update EMAIL_* variables to mirror SMTP_* (must be at the end)
force_update_email_variables

# Uninstall caddy
apt remove -y caddy

exit 0
