#!/usr/bin/env bash

BASE_DIR=$(cd `dirname $0` && pwd -P)

DIS_URL=${DIS_URL:-"consul://127.0.0.1:8500/default"}

docker run --net=host -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e MASTER_IP=${MASTER_IP} \
        -e DIS_URL=${DIS_URL} \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        -p swarm \
        up -d $*
