#!/usr/bin/env bash

PROJECT_ID=$(gcloud config get-value project)

if [[ -z "${PROJECT_ID}" ]]; then
  echo "Must run gcloud init first. Exiting."
  exit 0
fi

if [[ -z "${SERVICE_URL}" ]]; then
  echo "SERVICE_URL (URL of analysis-func service revealed after its deploy) env var must be set. Exiting."
  exit 0
fi

# Things shared between the pieces being deployed
APP_NAME="analysis-func"
TOPIC_NAME="feedback-created"
# Subscription name also becomes the name of the service account representing
# its identity
SUBSCRIPTION_NAME="${APP_NAME}-pubsub-invoker"


# Create a service account to represent the Pub/Sub subscription identity
# We can think of the app "owning" the subscription because the subscription stores
# a queue of messages for it and only it (any container Cloud Run starts for it) to process
# (https://cloud.google.com/run/docs/tutorials/pubsub)
gcloud iam service-accounts create $SUBSCRIPTION_NAME \
     --display-name "Analysis Function Pub/Sub Invoker"

# Create a Pub/Sub subscription with the service account:
# (https://cloud.google.com/run/docs/tutorials/pubsub)

# Give the invoker service account permission to invoke your service
gcloud run services add-iam-policy-binding $APP_NAME \
   "--member=serviceAccount:${SUBSCRIPTION_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
   --role=roles/run.invoker

# Create a Pub/Sub subscription with the service account
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic $TOPIC_NAME \
   --push-endpoint=${SERVICE_URL}/ \
   "--push-auth-service-account=${SUBSCRIPTION_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
