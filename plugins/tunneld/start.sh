#!/usr/bin/env bash

BASE_DIR=$(cd `dirname $0` && pwd -P)


docker run --net=host -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e API_SERVER=${API_SERVER} \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        up -d $*

if [[ ${PROVIDER} == "aws" ]]; then
    PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
elif  [[ ${PROVIDER} == "aliyun" ]]; then
    PUBLIC_IP=$(curl http://100.100.100.200/latest/meta-data/eipv4)
else
   echo "no such provider ${PROVIDER}"
    exit
fi

cp -f plugins/tunneld/tunneld-service.json.template plugins/tunneld/tunneld-service.json

sed -i -e "s#localhost#${PUBLIC_IP}#g" plugins/tunneld/tunneld-service.json

curl -H "Content-Type: application/json" -X POST -d @plugins/tunneld/tunneld-service.json http://127.0.0.1:6400/services/create