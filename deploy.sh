#!/usr/bin/env bash
set -euo pipefail

# -------- Config --------
AWS_PROFILE="${AWS_PROFILE:-default}"
AWS_REGION="${AWS_REGION:-eu-west-3}"
DIST="${DIST:-E22UNXV0CNOBQ9}"
BUCKET="${BUCKET:-portfolio-dev-www-zenabamogne-fr-site}"
SRC_DIR="${SRC_DIR:-infra/public}"       # répertoire source local

# -------- Helpers --------
need() { command -v "$1" >/dev/null 2>&1 || { echo "❌ Missing: $1"; exit 1; }; }
need aws

invalidate() {
  local path="$1"
  aws cloudfront create-invalidation \
    --distribution-id "$DIST" \
    --paths "$path" \
    --profile "$AWS_PROFILE" >/dev/null
  echo "🧹 Invalidation CloudFront: $path"
}

case "${1:-all}" in
  html)
    echo "🔼 Upload index.html (no-cache)"
    aws s3 cp "$SRC_DIR/index.html" "s3://$BUCKET/index.html" \
      --cache-control "no-cache, no-store, must-revalidate" \
      --content-type "text/html; charset=utf-8" \
      --metadata-directive REPLACE \
      --region "$AWS_REGION" --profile "$AWS_PROFILE"
    invalidate "/index.html"
    ;;

  pdf)
    FILE="CV_2025_MOGNE_ZENABA.pdf"
    echo "🔼 Upload $FILE (no-cache)"
    aws s3 cp "$SRC_DIR/$FILE" "s3://$BUCKET/$FILE" \
      --cache-control "no-cache, no-store, must-revalidate" \
      --content-type "application/pdf" \
      --metadata-directive REPLACE \
      --region "$AWS_REGION" --profile "$AWS_PROFILE"
    invalidate "/$FILE"
    ;;

  file)
    # Usage: ./deploy.sh file <local_name> <mime> [</cf/path>]
    FILE="$2"; TYPE="${3:-application/octet-stream}"; CF_PATH="${4:-/$2}"
    echo "🔼 Upload $FILE (custom)"
    aws s3 cp "$SRC_DIR/$FILE" "s3://$BUCKET/$FILE" \
      --cache-control "no-cache, no-store, must-revalidate" \
      --content-type "$TYPE" \
      --metadata-directive REPLACE \
      --region "$AWS_REGION" --profile "$AWS_PROFILE"
    invalidate "$CF_PATH"
    ;;

  all|*)
    echo "🔼 Sync assets (cache long) …"
    # Tout sauf index.html et PDF → cache long
    aws s3 sync "$SRC_DIR/" "s3://$BUCKET/" \
      --exclude ".DS_Store" \
      --exclude "index.html" \
      --exclude "*.pdf" \
      --delete \
      --region "$AWS_REGION" --profile "$AWS_PROFILE"

    # Pose le bon MIME + cache long pour quelques types courants
    # (facultatif : la détection MIME auto de S3 marche en général)
    aws s3 cp "$SRC_DIR/style.css" "s3://$BUCKET/style.css" \
      --cache-control "public, max-age=31536000, immutable" \
      --content-type "text/css; charset=utf-8" \
      --metadata-directive REPLACE \
      --region "$AWS_REGION" --profile "$AWS_PROFILE" || true

    # index.html (no-cache)
    echo "🔼 Upload index.html (no-cache) …"
    aws s3 cp "$SRC_DIR/index.html" "s3://$BUCKET/index.html" \
      --cache-control "no-cache, no-store, must-revalidate" \
      --content-type "text/html; charset=utf-8" \
      --metadata-directive REPLACE \
      --region "$AWS_REGION" --profile "$AWS_PROFILE"

    # robots.txt (cache court raisonnable)
    if [ -f "$SRC_DIR/robots.txt" ]; then
      aws s3 cp "$SRC_DIR/robots.txt" "s3://$BUCKET/robots.txt" \
        --cache-control "public, max-age=3600" \
        --content-type "text/plain; charset=utf-8" \
        --metadata-directive REPLACE \
        --region "$AWS_REGION" --profile "$AWS_PROFILE" || true
    fi

    invalidate "/*"
    ;;
esac

echo "✅ Done."