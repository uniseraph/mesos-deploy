#!/usr/bin/env bash


if [[ -z ${MASTER0_IP} ]]; then
    echo "Please export MASTER0_IP in your env"
    exit 1
fi

if [[ -z ${MASTER1_IP} ]]; then
    echo "Please export MASTER1_IP in your env"
    exit 1
fi

if [[ -z ${MASTER2_IP} ]]; then
    echo "Please export MASTER2_IP in your env"
    exit 1
fi




bash -x init-node.sh  && \
    bash -x start-bootstrap.sh  etcd zookeeper dnsmasq flanneld consul-server  && \
    bash -x start-docker.sh && \
    bash -x start-mesos.sh master slave


LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')
if [[ ${LOCAL_IP} == ${MASTER0_IP} ]]; then
    bash -x start-mesos.sh marathon mesos-consul
    echo "marathon starting success ......, Please access http://${LOCAL_IP}:8080"
fi

