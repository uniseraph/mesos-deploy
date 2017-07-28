#!/usr/bin/env bash

BASE_DIR=$(cd `dirname $0` && pwd -P)


INSTANCE_ID=$(curl 169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

if [[ -z ${AWS_ACCESS_KEY_ID} ]]; then
    echo "NO AWS_ACCESS_KEY_ID , exit watchdog-elbv2"
    exit
fi


if [[ -z ${AWS_SECRET_ACCESS_KEY} ]]; then
    echo "NO AWS_SECRET_ACCESS_KEY , exit watchdog-elbv2"
    exit
fi

docker run --net=host -ti --rm \
        -v ${BASE_DIR}:${BASE_DIR} \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -e INSTANCE_ID=${INSTANCE_ID} \
        -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}  \
        -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
        -e REGION=${REGION} \
        -w ${BASE_DIR} \
        docker/compose:1.9.0 \
        up -d $*
