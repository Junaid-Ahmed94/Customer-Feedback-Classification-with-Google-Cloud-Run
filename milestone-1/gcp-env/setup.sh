#!/usr/bin/env bash

PROJECT_ID=$(gcloud config get-value project)

if [[ -z "${PROJECT_ID}" ]]; then
  echo "Must run gcloud init first. Exiting."
  exit 0
fi

PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format json | jq --raw-output '.projectNumber')

echo "Beginning env setup."

# Setting up Cloud Run Environment
gcloud services enable --project $PROJECT_ID \
  cloudbuild.googleapis.com \
  appengine.googleapis.com \
  language.googleapis.com \
  sheets.googleapis.com \
  run.googleapis.com

# Create Pub/Sub topics
gcloud pubsub topics create feedback-created
gcloud pubsub topics create feedback-classified

echo "PubSub Topics created."

# Enable Pub/Sub to create authentication tokens in your project
gcloud projects add-iam-policy-binding $PROJECT_ID \
     "--member=serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com" \
     --role=roles/iam.serviceAccountTokenCreator
