#!/bin/bash

echo 'Building and deploying the latest Docker image'

project=$(grep -o '\"project_id\": \"[^\"]*' terraform.tfvars.json | grep -o '[^\"]*$')
region=$(grep -o '\"project_default_region\": \"[^\"]*' terraform.tfvars.json | grep -o '[^\"]*$')
runservice=$(grep -o '\"run_service_id\": \"[^\"]*' terraform.tfvars.json | grep -o '[^\"]*$')

gcloud builds submit --config=cloudbuild.yaml --project=$project --substitutions=_REGION=$region
gcloud run deploy $runservice --image=$region-docker.pkg.dev/$project/run-image/telemetry:latest --project=$project --region=$region



curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" -H "Content-Type: application/json" -d '{"key1": "value1", "key2": "value2"}' https://telemetry.jeremyto.demo.altostrat.com/collect