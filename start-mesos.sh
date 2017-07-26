#!/usr/bin/env bash



#LOCAL_IP=$(ifconfig eth0 | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}')


ZK_URL=${ZK_URL:-"zk://${MASTER0_IP}:2181,${MASTER1_IP}:2181,${MASTER2_IP}:2181"}

HOSTNAME=`hostname`

docker -H unix:///var/run/bootstrap.sock run -ti --rm \
        -v $(pwd):$(pwd) \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e ZK_URL=${ZK_URL} \
        -e HOSTNAME=${HOSTNAME} \
        -w $(pwd) docker/compose:1.9.0 \
        -f compose/mesos.yml \
        -p mesos \
        up -d $*



