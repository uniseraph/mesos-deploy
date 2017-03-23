#!/usr/bin/env bash


bash -x init-node.sh  && \
    bash -x start-bootstrap.sh  etcd zookeeper dnsmasq flanneld  && \
    bash -x start-docker.sh && \
    bash -x start-mesos.sh && \
    bash start-consul server mesos-consul