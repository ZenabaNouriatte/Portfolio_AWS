#!/usr/bin/env bash
set -euo pipefail
AWS_PROFILE=default
AWS_REGION=eu-west-3
DIST=E22UNXV0CNOBQ9
BUCKET=portfolio-dev-www-zenabamogne-fr-site

case "${1:-all}" in
  html)
    aws s3 cp infra/public/index.html s3://$BUCKET/public/index.html \
      --cache-control "no-cache, no-store, must-revalidate" \
      --content-type "text/html; charset=utf-8" \
      --metadata-directive REPLACE --region $AWS_REGION --profile $AWS_PROFILE
    aws cloudfront create-invalidation --distribution-id $DIST --paths "/index.html" --profile $AWS_PROFILE
    ;;
  file)
    # ex: ./deploy.sh file CV_2025_MOGNE_ZENABA.pdf application/pdf "/CV_2025_MOGNE_ZENABA.pdf"
    FILE="$2"; TYPE="${3:-application/octet-stream}"; PATH_CF="${4:-/$2}"
    aws s3 cp "infra/public/$FILE" "s3://$BUCKET/public/$FILE" --content-type "$TYPE" --region $AWS_REGION --profile $AWS_PROFILE
    aws cloudfront create-invalidation --distribution-id $DIST --paths "$PATH_CF" --profile $AWS_PROFILE
    ;;
  all|*)
    aws s3 sync infra/public/ s3://$BUCKET/public/ --delete --region $AWS_REGION --profile $AWS_PROFILE
    aws cloudfront create-invalidation --distribution-id $DIST --paths "/*" --profile $AWS_PROFILE
    ;;
esac
echo "✅ Done."
