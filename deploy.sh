#!/usr/bin/env bash

set -e

#variables
export NAME=k8s.shanelee.name.k8s.local
export KOPS_STATE_STORE=s3://shane-k8s-bucket


#Cluster kubeconfig and keygen (for key-pair generation)
mkdir -p ~/stacks/${NAME}
touch ~/stacks/${NAME}/kubeconfig
export KUBECONFIG=~/stacks/${NAME}/kubeconfig
mkdir -p  ~/stacks/${NAME}/credentials
#needs user input
ssh-keygen -t rsa -f  ~/stacks/${NAME}/credentials/id_rsa


echo "Create k8s gossip cluster"

kops create cluster --v=0 \
  --cloud=aws \
  --node-count 2 \
  --master-size=m3.medium \
  --master-zones=ap-southeast-2a \
  --zones ap-southeast-2a,ap-southeast-2c \
  --name= ${NAME} \
  --node-size=m3.medium \
  --node-volume-size=20 \
  --ssh-public-key=~/stacks/${NAME}/credentials/id_rsa.pub \
  2>&1 | tee ~/stacks/${NAME}/create_cluster.txt



kops update cluster ${NAME} --yes

echo "sleep for 5 mins to wait for cluster creation"
sleep 300

echo "kubectl version installed is  $(kubectl version)"

kops export kubecfg ${NAME}

echo "verify nodes are visible in cluster"

kubectl get nodes -o wide

echo "Install addons for cluster"
echo "Install dashboard"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

echo "Install heapster"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.7.0.yaml
