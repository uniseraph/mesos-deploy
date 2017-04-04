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
    bash -x start-bootstrap.sh  etcd zookeeper dnsmasq flanneld  && \
    bash -x start-docker.sh && \
    bash -x start-mesos.sh && \
    bash -x start-consul.sh server mesos-consul




  SECONDS=0
  while [[ $(curl -fsSL http://localhost:8080 2>&1 1>/dev/null; echo $?) != 0 ]]; do
    ((SECONDS++))
    if [[ ${SECONDS} ==



     ]]; then
      echo "marathon failed to start. Exiting..."
      exit 1
    fi
    sleep 1
  done

LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')

echo "marathon starting success ......, Please access http://${LOCAL_IP}:8080"