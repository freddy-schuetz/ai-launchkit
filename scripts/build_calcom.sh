#!/bin/bash
set -e

echo "========================================="
echo "Building Cal.com Docker image..."
echo "This will take 10-15 minutes on first build..."
echo "========================================="

# Clone repository if not exists
if [ ! -d "./calcom-docker" ]; then
    echo "Cloning Cal.com Docker repository..."
    git clone https://github.com/calcom/docker calcom-docker
fi

cd calcom-docker

# Update submodule (Cal.com source)
echo "Updating Cal.com source code..."
git pull
git submodule update --init

# --- Patch Dockerfile automatically ---
echo "Patching Dockerfile for Google Calendar integration..."

# 1. Insert ARG GOOGLE_API_CREDENTIALS, if not existing
if ! grep -q "ARG GOOGLE_API_CREDENTIALS" Dockerfile; then
    sed -i '/^ARG ORGANIZATIONS_ENABLED/a ARG GOOGLE_API_CREDENTIALS' Dockerfile
    echo "  -> Added ARG GOOGLE_API_CREDENTIALS"
else
    echo "  -> ARG GOOGLE_API_CREDENTIALS already exists."
fi

# 2. Insert GOOGLE_API_CREDENTIALS to ENV-Block, if not existing
if ! grep -q "GOOGLE_API_CREDENTIALS=\$GOOGLE_API_CREDENTIALS" Dockerfile; then
    # Add backslash
    sed -i 's/^\( *BUILD_STANDALONE=true\).*/\1 \\/' Dockerfile
    # Insert the new ENV-line WITH backslash at the end
    sed -i '/^\( *BUILD_STANDALONE=true\)/a \    GOOGLE_API_CREDENTIALS=$GOOGLE_API_CREDENTIALS \\' Dockerfile
    echo "  -> Added GOOGLE_API_CREDENTIALS to ENV block."
else
    echo "  -> GOOGLE_API_CREDENTIALS already in ENV block."
fi
# --- Patch yarn3/turbo comapility ---
echo "Patching Dockerfile for Yarn 3 compatibility..."

# Fix: npm instead of yarn global for turbo installation
if grep -q "RUN yarn global add turbo" Dockerfile; then
    sed -i 's/RUN yarn global add turbo/RUN npm install -g turbo/' Dockerfile
    echo "  -> Fixed: Using npm instead of yarn global for turbo"
else
    echo "  -> Turbo installation already fixed or not present."
fi

# Alternative: If yarn is needed
if grep -q "RUN yarn --cwd apps/web workspace @calcom/web run build" Dockerfile; then
    # Check for turbo availibility
    sed -i 's|RUN yarn --cwd apps/web workspace @calcom/web run build|RUN npx turbo run build --filter=@calcom/web|' Dockerfile
    echo "  -> Fixed: Using npx turbo for web build"
else
    echo "  -> Web build command already fixed or different."
fi
# --- End of Patch-Blocks ---


# Copy our .env values to build environment
if [ -f "../.env" ]; then
    echo "Using configuration from parent .env..."

    # Extract necessary variables
    DOMAIN=$(grep "^USER_DOMAIN_NAME=" ../.env | cut -d '=' -f2 | tr -d '"')
    POSTGRES_PASSWORD=$(grep "^POSTGRES_PASSWORD=" ../.env | cut -d '=' -f2 | tr -d '"')

    # Google Calendar Integration
    GOOGLE_CLIENT_ID=$(sed -n "s/^GOOGLE_CLIENT_ID=//p" ../.env | sed "s/['\"]//g")
    GOOGLE_CLIENT_SECRET=$(sed -n "s/^GOOGLE_CLIENT_SECRET=//p" ../.env | sed "s/['\"]//g")

    if [[ -n "$GOOGLE_CLIENT_ID" && -n "$GOOGLE_CLIENT_SECRET" ]]; then
        echo "Adding Google Calendar credentials..."
        GOOGLE_CREDS="{\"web\":{\"client_id\":\"${GOOGLE_CLIENT_ID}\",\"client_secret\":\"${GOOGLE_CLIENT_SECRET}\",\"redirect_uris\":[\"https://cal.${DOMAIN}/api/integrations/googlecalendar/callback\",\"https://cal.${DOMAIN}/api/auth/callback/google\"]}}"
    fi

    # Create .env for Cal.com build
    cat > .env << EOF
# Database (using AI LaunchKit's PostgreSQL)
DATABASE_URL=postgresql://postgres:${POSTGRES_PASSWORD}@postgres:5432/calcom
DATABASE_DIRECT_URL=postgresql://postgres:${POSTGRES_PASSWORD}@postgres:5432/calcom

# URLs
NEXT_PUBLIC_WEBAPP_URL=https://cal.${DOMAIN}
NEXT_PUBLIC_API_V2_URL=https://cal.${DOMAIN}/api/v2
NEXT_PUBLIC_WEBSITE_URL=https://cal.${DOMAIN}
NEXTAUTH_URL=https://cal.${DOMAIN}
CAL_URL=https://cal.${DOMAIN}

# Security
NEXTAUTH_SECRET=\$(openssl rand -base64 32)
CALENDSO_ENCRYPTION_KEY=\$(openssl rand -base64 32)

# Email
EMAIL_FROM=\${EMAIL_FROM:-noreply@\${DOMAIN}}
EMAIL_SERVER_HOST=\${SMTP_HOST:-mailpit}
EMAIL_SERVER_PORT=\${SMTP_PORT:-1025}
EMAIL_SERVER_USER=\${SMTP_USER:-}
EMAIL_SERVER_PASSWORD=\${SMTP_PASSWORD:-}
SEND_FEEDBACK_EMAIL=false

# Features
NEXT_PUBLIC_DISABLE_SIGNUP=false
TELEMETRY_DISABLED=1
EOF
    
    # Append the Google line separately. This is much safer.
    if [[ -n "$GOOGLE_CREDS" ]]; then
        echo "" >> .env
        echo "# Google Calendar Integration" >> .env
        echo "GOOGLE_API_CREDENTIALS=${GOOGLE_CREDS}" >> .env
    fi
fi

echo "========================================="
echo "Cal.com build preparation complete!"
echo "Image will be built when you run docker compose"
echo "========================================="
