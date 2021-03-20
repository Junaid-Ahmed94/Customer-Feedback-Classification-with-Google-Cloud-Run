#!/usr/bin/env bash

PROJECT_ID=$(gcloud config get-value project)
REGION="europe-west1"

if [[ -z "${PROJECT_ID}" ]]; then
  echo "Must run gcloud init first. Exiting."
  exit 0
fi

APP_NAME="trigger-func"

# Build image via Cloud Build
gcloud builds submit --tag "gcr.io/$PROJECT_ID/${APP_NAME}"

# Deploy with allowing unauthenticated requests, since it's anonymous
# HTTP clients who need to be able to send requests to it. This could be
# tightened in the future by setting up GCP authentication for the HTTP
# client sending the feedback if it supports it.
# Set CPU/memory to lowest allowed because it doesn't need a lot.
# Set max instances low to help prevent runaway bills during the project.
gcloud run deploy $APP_NAME \
  --image "gcr.io/$PROJECT_ID/${APP_NAME}" \
  --cpu "1.0" \
  --memory "128Mi" \
  --max-instances 1 \
  --platform managed \
  --allow-unauthenticated \
  --region $REGION

# Needed to ensure this deploy gets 100% of traffic if traffic was manualy
# adjusted for this service before.
gcloud run services update-traffic $APP_NAME --to-latest
