# Copyright 2017 Google, Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/env bash

set -e
docker build -t hellonode:v1 hellonode-app/
./minikube-ci-initialize.sh
./kubectl create -f hellonode-k8s-yaml/hellonode-rc.yaml
./kubectl create -f hellonode-k8s-yaml/hellonode-svc.yaml
HELLONODE_URL="$(./minikube service --url --wait=300 --interval=2 hellonode 2>/dev/null)"
export HELLONODE_URL
./hellonode-test.sh