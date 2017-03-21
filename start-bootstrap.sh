#!/usr/bin/env bash

LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')

HOST_IP=${HOST_IP:-$LOCAL_IP}

ETCD_URL=${ETCD_URL:-"http://"${HOST_IP}:2379}


docker -H unix:///var/run/bootstrap.sock run -ti --rm -v $(pwd):$(pwd) \
	-v /var/run/bootstrap.sock:/var/run/bootstrap.sock \
        -v /usr/bin/docker:/usr/bin/docker \
        -e DOCKER_HOST=unix:///var/run/bootstrap.sock  \
        -e HOST_IP=${HOST_IP} \
        -e ETCD_URL=${ETCD_URL} \
        -w $(pwd)  docker/compose:1.9.0 \
        -f compose/node-compose.yml \
        -p bootstrap \
        up -d $*



