const bodyParser = require('body-parser');
const express = require('express');
const _ = require('lodash');
const uuid = require('uuid').v4;

const config = {
  // Cloud Run provides port via env var
  port: process.env.PORT || 8080,
};

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

  res.status(201).send();
});

app.listen(config.port, () => {
  console.log(`trigger-func app listening at http://localhost:${config.port}`);
});
