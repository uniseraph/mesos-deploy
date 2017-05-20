#!/usr/bin/env bash

BASE_DIR=$(cd `dirname $0` && pwd -P)


LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')


DOCKER_HOST=${DIS_URL:-"${LOCAL_IP}:2375"}


docker run -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=${DOCKER_HOST}  \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        up -d $*
