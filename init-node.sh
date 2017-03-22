#!/usr/bin/env bash

yum install -y docker jq


cp -f systemd/bootstrap/bootstrap.service /etc/systemd/system/
#cp -f systemd/bootstrap/bootstrap.socket /etc/systemd/system/
cp -f systemd/bootstrap/bootstrap /etc/sysconfig/bootstrap


 rm -rf /tmp/docker-1.12.6.tgz && wget -o /tmp/docker-1.12.6.tgz https://get.docker.com/builds/Linux/x86_64/docker-1.12.6.tgz

tar zxvf /tmp/docker-1.12.6 && cp -rf /tmp/docker-1.12.6/* /usr/bin/


systemctl start bootstrap
systemctl status bootstrap

