#!/usr/bin/env bash

set -e

#variables
export NAME=k8s.shanelee.name.k8s.local
export KOPS_STATE_STORE=s3://shane-k8s-bucket
export KUBECONFIG=~/stacks/${NAME}/kubeconfig

echo "Delete cluster ${NAME}"

kops delete cluster ${NAME} --yes
rm -rf ~/stacks/${NAME}
