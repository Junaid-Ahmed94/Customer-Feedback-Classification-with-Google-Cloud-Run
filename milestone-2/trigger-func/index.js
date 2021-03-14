const bodyParser = require('body-parser');
const express = require('express');
const Firestore = require('@google-cloud/firestore');
const { PubSub } = require('@google-cloud/pubsub');
const _ = require('lodash');
const uuid = require('uuid').v4;

const config = {
  // Cloud Run provides port via env var
  port: process.env.PORT || 8080,
};

// Deploying to Cloud Run, which already has access to a service account
// (https://cloud.google.com/run/docs/securing/service-identity) so no need
// to create a service account key and provide its path in the constructor
// options for the GCP clients, and no need to specify project ID.
const feedbackRef = new Firestore().collection('feedback');
const pubsubClient = new PubSub();

const app = express();

// Allows receiving JSON body requests for adding new feedback
app.use(bodyParser.json());

app.post('/', async (req, res) => {
  const input = req.body;

  // Validation
  if (_.isNil(input.feedback)) {
    res.status(400).send(`Missing input param "feedback".`);
    return;
  }

  const newFeedbackId = uuid();

  // Save validated feedback
  try {
    const newFeedback = input;   

    newFeedback.createdAt = new Date().toISOString();
    newFeedback.classified = false;

    await feedbackRef.doc(newFeedbackId).set(newFeedback);
    console.log(`New feedback saved in Firestore (new feedback ID = ${newFeedbackId}).`);

    // Notify via Pub/Sub that feedback was created.
    const msg = JSON.stringify({
      newFeedbackId,
    });
    await pubsubClient.topic('feedback-created').publish(Buffer.from(msg));
    console.log(`Message published to Pub/Sub (new feedback ID = ${newFeedbackId}).`);

    res.status(201).send();
    return;
  } catch (e) {
    console.log(`Error saving feedback (new feedback ID = ${newFeedbackId}):`, e);

    res.status(500).send();
    return;
  }
});

app.listen(config.port, () => {
  console.log(`trigger-func app listening at http://localhost:${config.port}`);
});
