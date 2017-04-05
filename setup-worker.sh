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
    bash -x start-bootstrap.sh  dnsmasq flanneld consul-agent  && \
    bash -x start-docker.sh && \
    bash -x start-mesos.sh  slave 
    #bash -x start-consul.sh  agent mesos-consul