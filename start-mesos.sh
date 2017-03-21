#!/usr/bin/env bash



LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')

HOST_IP=${HOST_IP:-$LOCAL_IP}
ZK_URL=${ZK_URL:-"zk://${HOST_IP}:2181/default"}


docker -H unix:///var/run/bootstrap.sock run -ti --rm \
        -v $(pwd):$(pwd) \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e ZK_URL=${ZK_URL} \
        -w $(pwd)  docker/compose:1.9.0 \
        -f compose/mesos.yml \
        -p mesos \
        up -d $*
