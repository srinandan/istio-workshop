#!/bin/bash
docker push gcr.io/$PROJECT_ID/websockets
docker tag websockets gcr.io/$PROJECT_ID/websockets