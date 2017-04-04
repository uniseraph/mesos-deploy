#!/usr/bin/env bash


LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')

#HOST_IP=${HOST_IP:-$LOCAL_IP}
ZK_URL=${ZK_URL:-"zk://${MASTER0_IP}:2181,${MASTER1_IP}:2181,${MASTER2_IP}:2181"}

BOOTSTRAP_EXPECT=${BOOTSTRAP_EXPECT:-1}

docker -H unix:///var/run/bootstrap.sock run -ti --rm \
        -v $(pwd):$(pwd) \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e MASTER1_IP=${MASTER1_IP} \
        -e MASTER2_IP=${MASTER2_IP} \
        -e MASTER0_IP=${MASTER0_IP} \
        -e ZK_URL=${ZK_URL} \
        -e BOOTSTRAP_EXPECT=${BOOTSTRAP_EXPECT} \
        -w $(pwd)  docker/compose:1.9.0 \
        -f compose/consul.yml \
        -p consul \
        up -d $*
