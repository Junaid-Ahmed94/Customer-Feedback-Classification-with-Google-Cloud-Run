#!/usr/bin/env bash

echo "Beginning env teardown."

# Delete Pub/Sub topics
gcloud pubsub topics delete feedback-created feedback-classified
