#!/usr/bin/env bash

docker build -t php-redis:v1 -f guestbook/php-redis/Dockerfile guestbook/php-redis/
docker build -t redis-slave:v1 -f guestbook/redis-slave/Dockerfile guestbook/redis-slave/ 
./minikube-ci-initialize.sh
./guestbook-test.sh