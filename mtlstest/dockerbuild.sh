#!/bin/bash
docker build -t mtlstest .
docker tag mtlstest gcr.io/$PROJECT_ID/mtlstest:latest
gcloud docker -- push gcr.io/$PROJECT_ID/mtlstest:latest
