#!/usr/bin/env bash

set -e
docker build -t hellonode:v1 hellonode-app/
./minikube-ci-initialize.sh
./kubectl create -f hellonode-k8s-yaml/hellonode-rc.yaml
./kubectl create -f hellonode-k8s-yaml/hellonode-svc.yaml
HELLONODE_URL="$(./minikube service --url --wait=300 --interval=2 hellonode 2>/dev/null)"
export HELLONODE_URL
./hellonode-test.sh