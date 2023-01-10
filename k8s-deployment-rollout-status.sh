#!/bin/bash

#k8s-deployment-rollout-status.sh

sleep 60s

if [[ $(kubectl -n default rollout status deploy ${deploymentNAme} --timeout 5s) != *"successfully rolled out"* ]];
then
    echo "Deployment ${deploymentName} Rollout has Failed"
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1;
else
    echo "Deloyment ${deploymentName} Rollout is Success"
fi