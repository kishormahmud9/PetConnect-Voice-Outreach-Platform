#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# docker-entrypoint.sh
# Validates required environment variables, then launches the application.
# ─────────────────────────────────────────────────────────────────────────────
set -e

echo "============================================================"
echo " VetPay Outbound Call Agent — Starting"
echo "============================================================"

# ── Validate required environment variables ──────────────────────────────────
REQUIRED_VARS=(
    "TWILIO_ACCOUNT_SID"
    "TWILIO_AUTH_TOKEN"
    "TWILIO_PHONE_NUMBER"
    "ELEVENLABS_API_KEY"
    "BASE_URL"
    "HUMAN_AGENT_NUMBER"
    "COMMON_MESSAGE_TEXT"
    "JWT_SECRET_KEY"
)

MISSING=()
for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        MISSING+=("$VAR")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "ERROR: The following required environment variables are missing:"
    for VAR in "${MISSING[@]}"; do
        echo "  - $VAR"
    done
    echo "Please set them in your .env file or docker-compose environment section."
    exit 1
fi

echo "✓ All required environment variables are set."
echo "✓ BASE_URL: ${BASE_URL}"
echo "✓ TWILIO_PHONE_NUMBER: ${TWILIO_PHONE_NUMBER}"
echo "============================================================"

# ── Ensure runtime directories exist ─────────────────────────────────────────
mkdir -p /app/audio /app/output_results

# ── Start the application ─────────────────────────────────────────────────────
exec "$@"
