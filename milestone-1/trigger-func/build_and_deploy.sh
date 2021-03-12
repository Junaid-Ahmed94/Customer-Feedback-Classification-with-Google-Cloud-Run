#!/usr/bin/env bash

PROJECT_ID=$(gcloud config get-value project)

if [[ -z "${PROJECT_ID}" ]]; then
  echo "Must run gcloud init first. Exiting."
  exit 0
fi

APP_NAME="trigger-func"

# Build image via Cloud Build
gcloud builds submit --tag "gcr.io/$PROJECT_ID/trigger-func"

gcloud run deploy $APP_NAME \
  --image "gcr.io/$PROJECT_ID/trigger-func" \
  --cpu "1.0" \
  --memory "128Mi" \
  --max-instances 1 \
  --platform managed \
  --allow-unauthenticated \
  --region europe-west1

# Needed to ensure this deploy gets 100% of traffic if traffic was manualy
# adjusted for this service before.
gcloud run services update-traffic $APP_NAME --to-latest
