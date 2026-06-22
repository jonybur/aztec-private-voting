#!/usr/bin/env bash
# deploy-stimuli.sh — Deploy PIUP Study 1 stimuli to Vercel
# Usage: bash scripts/deploy-stimuli.sh [--prod]
#
# Vercel CLI must be installed and authenticated:
#   npm i -g vercel
#   vercel login
#
# On first run, Vercel will prompt to link the project.
# After first run, subsequent deploys are fully non-interactive.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STIMULI_DIR="$REPO_ROOT/study-stimuli"

echo "=== PIUP Study 1 Stimulus Deployer ==="
echo "Source: $STIMULI_DIR"
echo ""

# Verify all 4 condition files exist
REQUIRED=(
  "condition-a-fingerprint.html"
  "condition-b-confirmation-code.html"
  "condition-c-nullifier.html"
  "condition-d-receipt-id.html"
  "vercel.json"
  "index.html"
)
for f in "${REQUIRED[@]}"; do
  if [[ ! -f "$STIMULI_DIR/$f" ]]; then
    echo "ERROR: Missing required file: study-stimuli/$f" >&2
    exit 1
  fi
done
echo "✓ All required files present"
echo ""

# Deploy
PROD_FLAG=""
if [[ "${1:-}" == "--prod" ]]; then
  PROD_FLAG="--prod"
  echo "Deploying to PRODUCTION..."
else
  echo "Deploying preview (pass --prod for production)..."
fi

cd "$STIMULI_DIR"
DEPLOY_URL=$(npx vercel deploy $PROD_FLAG --yes 2>&1 | tail -1)
echo ""
echo "=== Deploy complete ==="
echo "URL: $DEPLOY_URL"
echo ""

if [[ -n "$PROD_FLAG" ]]; then
  echo "Condition URLs for Prolific:"
  echo "  Condition A: $DEPLOY_URL/condition-a-fingerprint.html"
  echo "  Condition B: $DEPLOY_URL/condition-b-confirmation-code.html"
  echo "  Condition C: $DEPLOY_URL/condition-c-nullifier.html"
  echo "  Condition D: $DEPLOY_URL/condition-d-receipt-id.html"
  echo ""
  echo "Verification index: $DEPLOY_URL/index.html"
  echo ""
  echo "Next steps:"
  echo "  1. Open each condition URL — verify label + layout"
  echo "  2. Test Qualtrics iframe embed"
  echo "  3. Paste condition URLs into Prolific study URL fields"
  echo "  4. Run pilot (N=40, PILOT=TRUE in analysis/piup-study1-analysis.R)"
fi
