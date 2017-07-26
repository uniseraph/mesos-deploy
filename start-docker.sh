#!/usr/bin/env bash

SECONDS=0
while [[ ! -f /run/flannel/subnet.env ]]; do
  ((SECONDS++))
  if [[ ${SECONDS} == 999 ]]; then
    echo "flannel failed to start. Exiting..."
    exit 1
  fi
  sleep 1
done

source /run/flannel/subnet.env


systemctl stop docker


echo "DOCKER_OPTS=\"  --dns ${LOCAL_IP}  --ip-masq=${FLANNEL_IPMASQ}  --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} --log-driver=json-file --log-opt max-file=10 --log-opt max-size=100m -s overlay --registry-mirror=https://rmw18jx4.mirror.aliyuncs.com  \""  >> /etc/sysconfig/docker


    #aws／aliyun都需要，否则容器无法ping宿主机
    iptables -t nat  -A POSTROUTING -o eth0 -s ${FLANNEL_SUBNET}  -j MASQUERADE

systemctl restart docker
systemctl enable docker

