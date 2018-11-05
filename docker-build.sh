#!/bin/bash
PROJECT_ID="$(gcloud config get-value project -q)"
docker build -t gcr.io/${PROJECT_ID}/aet-tmn-member-app:v1 .
