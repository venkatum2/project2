#!/bin/bash
PROJECT_ID="$(gcloud config get-value project -q)"
docker run --rm -p 8081:80 gcr.io/${PROJECT_ID}/aet-tmn-member-app:v1
