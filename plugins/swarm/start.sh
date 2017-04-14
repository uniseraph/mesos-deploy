#!/usr/bin/env bash



LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')


DIS_URL=${DIS_URL:-"zk://${MASTER0_IP}:2181,${MASTER1_IP}:2181,${MASTER2_IP}:2181/default"}

HOSTNAME=`hostname`

docker run -ti --rm \
        -v $(pwd):$(pwd) \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e DIS_URL=${DIS_URL} \
        -w $(pwd) \
        docker/compose:1.9.0 \
        -p swarm \
        up -d $*
