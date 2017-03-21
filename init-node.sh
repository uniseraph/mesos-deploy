#!/usr/bin/env bash

yum install -y docker jq


cp -f bootstrap/bootstrap.service /etc/systemd/system/
cp -f bootstrap/bootstrap.socket /etc/systemd/system/
cp -f bootstrap/bootstrap /etc/sysconfig/bootstrap


systemctl start bootstrap
systemctl status bootstrap

