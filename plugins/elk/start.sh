#!/usr/bin/env bash

BASE_DIR=$(cd `dirname $0` && pwd -P)


#LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')
#LOCAL_IP=$(ifconfig eth0 | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}')

MASTER_IP=${MASTER_IP:-${LOCAL_IP}}

ES_NAME="es0"


docker run -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	      -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e MASTER_IP=${MASTER_IP} \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        up -d $*
