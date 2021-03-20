# campos-live-proj-impl

This is the reference implementation of the Cloud Run version of the liveProject.

## Setup and teardown

## GCP setup

Create a new GCP project by signing into the GCP web console. Save this Project ID for use throughout the project.

### Workstation setup

You can install all the tools you need manually, but if you're using Ubuntu, you also have the option of using the scripts in `workstation-setup` to install the tools you need to complete the liveProject:

1. Run `install_gcloud_ubuntu.sh`. This installs the gcloud CLI tool to your home directory. This is the recommended way to install gcloud to be able to install gcloud components with `gcloud components ...` commands.
1. In a new terminal, run `gcloud init` and follow the prompt in your default web browser to authenticate gcloud. This wizard will also ask you to select the project you're working in. The Project ID set in the gcloud config after this process is completed will be read by the deploy scripts in the repo.
1. Run `sudo apt install -y jq`. The jq tool (https://github.com/stedolan/jq) is used by future scripts that involve parsing gcloud output.
1. Optionally, install Docker (https://docs.docker.com/engine/install/ubuntu/) to be able to build and run containers on your workstation, which may help you develop more easily.

### GCP project setup

Run the `gcp_env/setup.sh` script to set up your GCP environment for the first time. This enables the required APIs and creates the required Pub/Sub topics.

Some steps are difficult to automate, like sharing the Google Sheet with the service account associated with the `reporting-func` application in Milestone 4, and setting up the GitHub repo secrets for automating deploys with GitHub Actions in Milestone 5. Those steps should be performed manually as you reach each milestone.

To setup GitHub Actions, create a service account to use to deploy the applications from GitHub Actions, create a key file for it, and use that has the secret you set in the repo. This guide (https://github.com/google-github-actions/setup-gcloud/tree/master/example-workflows/cloud-run) can be used as reference.

To share your Google Sheets sheet with the service account associated with the Cloud Run apps, make a sheet and click "Share" in the top right corner. For the person to share with, use your default compute engine service account, which you can find in the IAM section of the GCP web UI. Use "Editor" permission:

![screenshot of sharing the Google Sheet](img/share_sheet.png)

### GCP project teardown

Run the `gcp_env/teardown.sh` script when you're finished working. This doesn't delete the GCP project, but it deletes other resources created like the Pub/Sub topics.

## Deploying each application

Run the `build_and_deploy.sh` script in each application directory to deploy it. Check each deploy script for necessary config (like the SHEET_ID of the Google Sheet in Milestone 4) before running.

if the application directory has a `create_subscription.sh` script too, run this after running the `build_and_deploy.sh` script after setting the `SERVICE_URL` env var (so that the subscription can be created to push messages to the URL).

**These deployment scripts are provided for reference, and when edited so you can use them to deploy, they include some secrets (like SHEET_ID). After you complete Milestone 5, you will have an automated deployment pipeline. GitHub repo secrets should be used for secrets like this in the real world.**

Note that for the GitHub Actions workflow to work, your main branch in your GitHub repo must be called `main`, and each of the applications must have been deployed manually using the `build_and_deploy.sh` and `create_subscription.sh` scripts.

# Testing

## Sending single request

You can use the script `send_test_request.sh` after deploying each application at least once and noting the URL assigned to the `trigger-func` application. Then, you can check GCP and Google Sheets to see your feedback.

For example:

```bash
./send_test_request.sh "this product was great!"
```

## Sending multiple requests (Milestone 5)

For Milestone 5, you will at some point, have multiple revisions deployed at once, one for v1 and one for v2. To see the effects of gradually increasing the share of traffic that v2 gets, you can use the `send_test_requests_continuous.sh` script. It sends one positive and one negative feedback each second. As v2 takes over, you'll see the share of v2 rows ending up in the Google Sheets sheet increase.

## Logs

You will see the logs in Logging:

![screenshot of logs in Logging](img/logs.png)

## Firestore

You will see the document saved in Firestore:

![screenshot of logs in Logging](img/firestore.png)

## Google Sheets

You will see a row appended to your Google Sheets sheet. If you run the test script with a browser tab open showing the sheet, you will see the feedback appended to it in real time:

![screenshot of logs in Logging](img/google_sheet.png)

# CI/CD with GitHub Actions

When changes are merged into the `main` branch, each app is automatically build and deployed to Cloud Run by the GitHub Actions workflow:

![screenshot of deploys](img/github_actions_workflow_deploys.png)

To be compatible the human-driven deployment process that the `reporting-func` app uses in Milestone 5, the automated deploy for `reporting-func` is set to no traffic. Once the workflow is complete, a privileged user can use the `gcloud run services update-traffic` command with the revision name output in the workflow logs to increment the share of traffic the newly-deployed revision gets as they wish.

For example, to move 10% of the traffic from the previous deploy to the new revision:

```bash
gcloud run services update-traffic reporting-func --to-revisions=reporting-func-00023-jex=10
```
