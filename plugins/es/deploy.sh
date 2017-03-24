#!/usr/bin/env bash


curl -k -XPOST -d @es.json -H "Content-Type: application/json" http://kvm1:8080/v2/apps
