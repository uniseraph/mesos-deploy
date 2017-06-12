#!/usr/bin/env bash

echo "net.ipv4.conf.eth0.rp_filter=0" > /etc/sysctl.d/omega.conf

sysctl -w net.ipv4.conf.eth0.rp_filter=0
sysctl -w vm.max_map_count=262144

cp sysctl.conf /etc/sysctl.conf
sysctl -p

yum install -y docker jq bind-utils bridge-utils tcpdump dnsmasq haveged strace pstack htop iostat vmstat curl wget sysdig pidstat mpstat iotop blktrace perf  dstat ltrace lsof

systemctl enable haveged
systemctl restart haveged

cp -f systemd/bootstrap/bootstrap.service /etc/systemd/system/
cp -f systemd/bootstrap/bootstrap /etc/sysconfig/bootstrap

cp -f systemd/dnsmasq/dnsmasq.service /usr/lib/systemd/system/dnsmasq.service


tar zxvf binary/docker-1.12.6.tgz && cp -rf docker/* /usr/bin/  && rm -rf docker 

systemctl daemon-reload
systemctl start bootstrap
systemctl enable bootstrap
systemctl status bootstrap -l

pip install --upgrade pip
pip install docker-compose

#pip install -U pip setuptools
#pip install docker-py
#curl -L https://bit.ly/glances | /bin/bash

#mkdir /etc/glances
#cp -f systemd/glances/glances.service /etc/systemd/system/
#cp -f systemd/glances/glances.conf  /etc/glances/glances.conf

#systemctl start dnsmasq
#systemctl status dnsmasq -l
