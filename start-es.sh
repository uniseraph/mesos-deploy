#!/usr/bin/env bash


sysctl -w  vm.max_map_count=262144

docker -H unix:///var/run/bootstrap.sock run -ti --rm \
        -v $(pwd):$(pwd) \
	    -v /var/run/docker.sock:/var/run/docker.sock \
        -e DOCKER_HOST=unix:///var/run/docker.sock  \
        -w $(pwd)  docker/compose:1.9.0 \
        -f compose/es.yml \
        -p es \
        up -d $*

