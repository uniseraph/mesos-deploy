# Copyright (c) 2015-2017, ANT-FINANCE CORPORATION. All rights reserved.

SHELL = /bin/bash


VERSION = $(shell cat VERSION)
GITCOMMIT = $(shell git log -1 --pretty=format:%h)
BUILD_TIME = $(shell date --rfc-3339 ns 2>/dev/null | sed -e 's/ /T/')


build:
	echo ${GITCOMMIT} > GITCOMMIT
	tar zcvf ~/mesos-deploy.tar.gz .

.PHONY: build
