#!/usr/bin/env bash

# Check for required env vars
if [[ -z "${URL}" ]]; then
  echo "URL env var must be set. Exiting."
  exit 0
fi
if [[ -z "${1}" ]]; then
  echo "Parameter 1 must be set (to the feedback to leave). Don't forget quotes! Exiting."
  exit 0
fi

FEEDBACK_CONTENT=$1

echo 'Expect 201:'
curl -XPOST -s -o /dev/null -w "%{http_code}" -H 'Content-Type: application/json' -d "{\"feedback\":\"${FEEDBACK_CONTENT}\"}" $URL
echo ''
