#!/usr/bin/env bash

#LOCAL_IP=$(ifconfig eth0 | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}')






ZK_URL=${ZK_URL:-"zk://${MASTER_IP}:2181"}
BOOTSTRAP_EXPECT=${BOOTSTRAP_EXPECT:-1}
FLANNEL_NETWORK=${FLANNEL_NETWORK:-"192.168.0.0/16"}


docker -H unix:///var/run/bootstrap.sock run --net=host -ti --rm -v $(pwd):$(pwd) \
	    -v /var/run/bootstrap.sock:/var/run/bootstrap.sock \
        -v /usr/bin/docker:/usr/bin/docker \
        -e DOCKER_HOST=unix:///var/run/bootstrap.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e MASTER_IP=${MASTER_IP} \
        -w $(pwd)  \
        docker/compose:1.9.0 \
        -f compose/bootstrap.yml \
        -p bootstrap \
        up -d $*




if [[ "${LOCAL_IP}" == "${MASTER_IP}" ]]; then
  SECONDS=0
  while [[ $(curl -fsSL http://${LOCAL_IP}:2379/health 2>&1 1>/dev/null; echo $?) != 0 ]]; do
    ((SECONDS++))
    if [[ ${SECONDS} == 99 ]]; then
      echo "etcd failed to start. Exiting..."
      exit 1
    fi
    sleep 1
  done

  curl -sSL http://${LOCAL_IP}:2379/v2/keys/coreos.com/network/config -XPUT \
      -d value="{ \"Network\": \"${FLANNEL_NETWORK}\",  \"SubnetLen\":25    ,   \"Backend\": {\"Type\": \"vxlan\"}}"
fi
