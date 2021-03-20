#!/usr/bin/env bash

REGION="europe-west1"

echo "Beginning env teardown."

# Delete Pub/Sub topics
gcloud pubsub topics delete feedback-created feedback-classified

# Delete Cloud Run service 
gcloud beta run services delete trigger-func --region=$REGION -q