# Copyright (c) 2015-2017, ANT-FINANCE CORPORATION. All rights reserved.

SHELL = /bin/bash


VERSION = $(shell cat VERSION)
GITCOMMIT = $(shell git log -1 --pretty=format:%h)
BUILD_TIME = $(shell date --rfc-3339 ns 2>/dev/null | sed -e 's/ /T/')


release:
	rm -rf release && mkdir -p release/mesos-deploy
	cp -r plugins release/mesos-deploy
	cp -r compose release/mesos-deploy
	cp -r systemd release/mesos-deploy
	cp *.conf release/mesos-deploy
	cp *.sh release/mesos-deploy
	cd release && tar zcvf mesos-deploy-${VERSION}-${GITCOMMIT}.tar.gz  mesos-deploy && cd ..



.PHONY: build release
