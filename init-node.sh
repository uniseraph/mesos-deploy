#!/usr/bin/env bash

echo "net.ipv4.conf.eth0.rp_filter=0" > /etc/sysctl.d/omega.conf

sysctl -p

yum install -y docker jq bind-utils bridge-utils tcpdump dnsmasq


cp -f systemd/bootstrap/bootstrap.service /etc/systemd/system/
#cp -f systemd/bootstrap/bootstrap.socket /etc/systemd/system/
cp -f systemd/bootstrap/bootstrap /etc/sysconfig/bootstrap

cp -f systemd/dnsmasq/dnsmasq.service /usr/lib/systemd/system/dnsmasq.service


tar zxvf binary/docker-1.12.6.tgz && cp -rf docker/* /usr/bin/  && rm -rf docker 

systemctl daemon-reload
systemctl start bootstrap
systemctl status bootstrap -l


#systemctl start dnsmasq
#systemctl status dnsmasq -l
