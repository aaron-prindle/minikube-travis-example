#!/usr/bin/env bash

set -e
HELLONODE_OUTPUT="$(curl $HELLONODE_URL)"
if [ "$HELLONODE_OUTPUT" != "HELLO" ]; then
  echo "TEST FAILURE: Unexpected output from hellonode service"
  exit 1
fi
echo "TEST SUCCESS: Expected output recieved from hellonode service"