#!/usr/bin/env bash

BASE_DIR=$(cd `dirname $0` && pwd -P)

#LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')
LOCAL_IP=$(ifconfig eth0 | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}')


docker run --net=host -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e LOCAL_IP=${LOCAL_IP} \
        -e API_SERVER=${API_SERVER} \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        up -d $*


PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)


cp -f plugins/tunneld/tunneld-service.json.template plugins/tunneld/tunneld-service.json

sed -i -e "s#localhost#${PUBLIC_IP}#g" plugins/tunneld/tunneld-service.json

curl -H "Content-Type: application/json" -X POST -d @plugins/tunneld/tunneld-service.json http://${LOCAL_IP}:6400/services/create