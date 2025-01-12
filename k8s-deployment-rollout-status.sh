#!/bin/bash

#k8s-deployment-rollout-status.sh

if [[ $(kubectl -n default rollout status deployment/${deploymentName} --timeout 5s) != *"successfully rolled out"* ]];
then
    echo "Deployment ${deploymentName} Rollout has Failed"
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1;
else
    echo "Deloyment ${deploymentName} Rollout is Success"
fi