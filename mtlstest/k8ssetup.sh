#!/bin/bash
kubectl create -f <(istioctl kube-inject -f mtlstest.yaml) --validate=true --dry-run=false
