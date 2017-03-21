#!/usr/bin/env bash

SECONDS=0
while [[ ! -f /run/flannel/subnet.env ]]; do
  ((SECONDS++))
  if [[ ${SECONDS} == 10 ]]; then
    echo "flannel failed to start. Exiting..."
    exit 1
  fi
  sleep 1
done

source /run/flannel/subnet.env

LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')

HOST_IP=${HOST_IP:-$LOCAL_IP}
ZK_URL=${ZK_URL:-"zk://${HOST_IP}:2181/default"}


echo '# /etc/sysconfig/docker-network'  > /etc/sysconfig/docker-network
echo "DOCKER_NETWORK_OPTIONS=\" --dns ${LOCAL_IP} --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}\""  >> /etc/sysconfig/docker-network


echo 'STORAGE_DRIVER=devicemapper' > /etc/sysconfig/docker-storage-setup

systemctl start docker
systemctl status docker -l



docker -H unix:///var/run/bootstrap.sock run -ti --rm \
        -v $(pwd):$(pwd) \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e HOST_IP=${HOST_IP} \
        -e ZK_URL=${ZK_URL} \
        -w $(pwd)  docker/compose:1.9.0 \
        -f compose/mesos.yml \
        -p mesos \
        up -d



docker -H unix:///var/run/bootstrap.sock run -ti --rm \
        -v $(pwd):$(pwd) \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e HOST_IP=${HOST_IP} \
        -e LOCAL_IP=${LOCAL_IP} \
        -e ZK_URL=${ZK_URL} \
        -w $(pwd)  docker/compose:1.9.0 \
        -f compose/mesos.yml \
        -p consul \
        up -d