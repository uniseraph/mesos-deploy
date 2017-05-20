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

systemctl stop docker

sed -i  's/--log-driver=journald/--log-driver=json-file --log-opt max-file=10 --log-opt max-size=100m/g' /etc/sysconfig/docker
echo '# /etc/sysconfig/docker-network'  > /etc/sysconfig/docker-network
echo "DOCKER_NETWORK_OPTIONS=\" -H unix:///var/run/docker.sock -H ${LOCAL_IP}:2376  --dns ${LOCAL_IP}  --ip-masq=${FLANNEL_IPMASQ}  --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}  --registry-mirror=https://rmw18jx4.mirror.aliyuncs.com  \""  >> /etc/sysconfig/docker-network


#echo 'STORAGE_DRIVER=devicemapper' > /etc/sysconfig/docker-storage-setup
#echo 'DOCKER_STORAGE_OPTIONS="-s devicemapper"' > /etc/sysconfig/docker-storage

systemctl start docker
systemctl status docker -l
systemctl enable docker

# for filebeat container
#chmod -R 755 /var/lib/docker

