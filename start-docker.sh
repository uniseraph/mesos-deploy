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

LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')

#HOST_IP=${HOST_IP:-$LOCAL_IP}
#ZK_URL=${ZK_URL:-"zk://${HOST_IP}:2181/default"}


systemctl stop docker

echo '# /etc/sysconfig/docker-network'  > /etc/sysconfig/docker-network
echo "DOCKER_NETWORK_OPTIONS=\" --dns ${LOCAL_IP}  --ip-masq=${FLANNEL_IPMASQ}  --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}  --registry-mirror=https://rmw18jx4.mirror.aliyuncs.com  \""  >> /etc/sysconfig/docker-network


echo 'STORAGE_DRIVER=devicemapper' > /etc/sysconfig/docker-storage-setup
echo 'DOCKER_STORAGE_OPTIONS="-s devicemapper"' > /etc/sysconfig/docker-storage

systemctl start docker
systemctl status docker -l




