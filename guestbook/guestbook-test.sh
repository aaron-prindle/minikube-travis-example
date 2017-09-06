#!/usr/bin/env bash

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

# Run all kubernetes components for the guestbook
./kubectl create -f all-in-one/guestbook-all-in-one.yaml
# ======
# Test that writes to guestbook fronted and checks that a value is propogated to redis-master/slave and frontend
# ======

# Check that redis-master and redis-slave are operational
# redis-slave/master is an internal service so clusterIP must be used
REDIS_MASTER_IP="$(./kubectl get svc redis-master -o go-template='{{ .spec.clusterIP }}{{ "\n" }}')"
REDIS_SLAVE_IP="$(./kubectl get svc redis-slave -o go-template='{{ .spec.clusterIP }}{{ "\n" }}')"
REDIS_UP="false"
for i in {1..150} # timeout for 5 minutes
do
   if [ "$(redis-cli -h $REDIS_MASTER_IP <<< "PING")" == "PONG" ]; then
     if [ "$(redis-cli -h $REDIS_SLAVE_IP <<< "PING")" == "PONG" ]; then   
       REDIS_UP="true"
       break
     fi
   fi
  sleep 2
done
if [ "$REDIS_UP" != "true" ]; then
  echo "TEST FAILURE: redis-master was not accepting requests in allotted time"
  exit 1
fi

FRONTEND_URL="$(./minikube service --url --wait=300 --interval=2 frontend 2>/dev/null)"
KEY=TEST
# Simulate writing to guestbook with value "TEST"
curl --connect-timeout 5 \
     --max-time 10 \
     --retry 5 \
     --retry-delay 5 \
     --retry-max-time 300 \
     "$FRONTEND_URL/guestbook.php?cmd=set&key=messages&value=,$KEY" &> /dev/null

# Get the values from redis-master for the key "messages"
REDIS_MASTER_KEY_FOUND="false"
for i in {1..150} # timeout for 5 minutes
do
  REDIS_MASTER_OUTPUT=$(redis-cli -h $REDIS_MASTER_IP <<< "MGET messages")
  if grep -q $KEY <<<$REDIS_MASTER_OUTPUT; then
    echo "TEST SUCCESS: $KEY value found in redis-master"
    REDIS_MASTER_KEY_FOUND="true"
    break
  fi
  sleep 2
done
if [ "$REDIS_MASTER_KEY_FOUND" != "true" ]; then
  echo "TEST FAILURE: $KEY value not found in redis-master in allotted time"
  exit 1
fi

# Get the values from redis-slave for the key "messages"
REDIS_SLAVE_KEY_FOUND="false"
for i in {1..150} # timeout for 5 minutes
do
  REDIS_SLAVE_OUTPUT=$(redis-cli -h $REDIS_SLAVE_IP <<< "MGET messages")
  if grep -q $KEY <<<$REDIS_SLAVE_OUTPUT; then
    echo "TEST SUCCESS: $KEY value found in redis-slave"
    REDIS_SLAVE_KEY_FOUND="true"
    break
  fi
  sleep 2
done
if [ "$REDIS_SLAVE_KEY_FOUND" != "true" ]; then
  echo "TEST FAILURE: $KEY value not found in redis-slave in allotted time"
  exit 1
fi

# Get the values from redis-slave for the key "messages"
FRONTEND_KEY_FOUND="false"
for i in {1..150} # timeout for 5 minutes
do
  FRONTEND_OUTPUT=$(google-chrome-stable --headless --disable-gpu --dump-dom $FRONTEND_URL)
  if grep -q $KEY <<<$FRONTEND_OUTPUT; then
    echo "TEST SUCCESS: $KEY value found in frontend"
    FRONTEND_KEY_FOUND="true"
    break
  fi
  sleep 2
done
if [ "$FRONTEND_KEY_FOUND" != "true" ]; then
  echo "TEST FAILURE: $KEY value not found in frontend in allotted time"
  exit 1
fi
echo "TEST SUCCESS"