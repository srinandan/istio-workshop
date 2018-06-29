#!/bin/bash
curl -u $1:$2 -F "file=@details.zip" https://api.enterprise.apigee.com/v1/organizations/$3/apis?action=import&name=details

curl -u $1:$2 -H "Content-Type: application/x-www-form-urlencoded" https://api.enterprise.apigee.com/v1/organizations/$3/environments/$4/apis/details/revisions/1/deployments