#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# setup-portal.sh — Publish the APIM Developer Portal with a welcome message
#
# Usage: ./scripts/setup-portal.sh <apim-name> <resource-group> <subscription-id>
#
# Prerequisites:
#   - Azure CLI authenticated (`az login`)
#   - Developer Portal provisioned at least once via the Azure Portal admin UI
#
# This script is idempotent — safe to run multiple times.
# ---------------------------------------------------------------------------

APIM_NAME="${1:?Usage: $0 <apim-name> <resource-group> <subscription-id>}"
RG="${2:?Usage: $0 <apim-name> <resource-group> <subscription-id>}"
SUB_ID="${3:?Usage: $0 <apim-name> <resource-group> <subscription-id>}"

BASE="https://management.azure.com/subscriptions/${SUB_ID}/resourceGroups/${RG}/providers/Microsoft.ApiManagement/service/${APIM_NAME}"
API_VERSION="api-version=2022-08-01"

echo "==> Checking portal provisioning status..."
REVISIONS=$(az rest --method get \
  --url "${BASE}/portalRevisions?${API_VERSION}" \
  --query "value | length(@)" -o tsv 2>/dev/null || echo "0")

if [ "$REVISIONS" -eq 0 ]; then
  echo "ERROR: Developer Portal has not been provisioned yet."
  echo "Please open the portal admin UI first:"
  echo "  Azure Portal -> APIM -> Developer portal -> click 'Developer portal' link in toolbar"
  echo "Then run this script again."
  exit 1
fi

echo "==> Updating home page welcome text..."
WELCOME_ID="welcome-message"
az rest --method put \
  --url "${BASE}/contentTypes/document/contentItems/${WELCOME_ID}?${API_VERSION}" \
  --body '{
    "properties": {
      "en_us": {
        "title": "Welcome",
        "description": "Welcome to the Coupang AI Platform API Portal",
        "content": "## Getting Started\n\n1. **Sign up** for an account using the link above\n2. **Contact your team administrator** to be assigned to your project group\n3. Once assigned, visit the **Products** page to subscribe and get your **Personal API Key**\n4. Use your Personal Key to call the API — see the [User Quickstart Guide](https://github.com/jihys/apim-foundry-cost-governance/blob/main/docs/guidebook/04-user-quickstart.md) for details\n\nNeed help? Contact the AI Platform team."
      }
    }
  }' -o none 2>/dev/null || echo "Note: Custom document update may require admin portal to be opened first."

echo "==> Publishing portal revision..."
REVISION_NAME="auto-$(date +%Y%m%d%H%M%S)"
az rest --method put \
  --url "${BASE}/portalRevisions/${REVISION_NAME}?${API_VERSION}" \
  --body "{\"properties\":{\"description\":\"Automated publish with welcome message\",\"isCurrent\":true}}" \
  -o none

echo "==> Done! Portal published as revision: ${REVISION_NAME}"
echo "    Portal URL: https://${APIM_NAME}.developer.azure-api.net"
