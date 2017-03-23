#!/usr/bin/env bash

# Make sure MASTER_IP is properly set
if [[ -z ${HOST_IP} ]]; then
    echo "Please export HOST_IP in your env"
    exit 1
fi


bash -x init-node.sh  && \
    bash -x start-bootstrap.sh  dnsmasq flanneld  && \
    bash -x start-docker.sh && \
    bash -x start-mesos.sh  slave && \
    bash -x start-consul.sh  agent mesos-consul