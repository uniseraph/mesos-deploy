#!/usr/bin/env bash

echo "net.ipv4.etc.eth0.rp_filter=0" > /etc/sysctl.d/omega.conf

sysctl -w net.ipv4.conf.eth0.rp_filter=0
sysctl -w vm.max_map_count=262144

cp sysctl.conf /etc/sysctl.conf
sysctl -p

#yum install -y  jq bind-utils bridge-utils tcpdump dnsmasq haveged strace pstack htop iostat vmstat curl wget sysdig pidstat mpstat iotop blktrace perf  dstat ltrace lsof
apt-get update && apt-get install -y jq  bridge-utils tcpdump dnsmasq haveged strace pstack htop  curl wget  iotop blktrace   dstat ltrace lsof

#rpm -i binary/zanecloud-docker-1.11.1-d349391.x86_64.rpm
#systemctl enable haveged
#systemctl restart haveged

rm -rf d349391 && mkdir -p d349391 && cd d349391
wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-1.11.1
wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd
wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd-ctr
wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd-shim
wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-runc

cd ..
sudo chmod +x d349391/*
sudo mv d349391/docker-1.11 d349391/docker
sudo cp -f  d349391/* /usr/bin/


sudo mkdir -p /etc/sysconfig
cp -f systemd/docker-1.11/docker.service /etc/systemd/system/
cp -f systemd/docker-1.11/docker.socket /etc/systemd/system/

cp -f systemd/bootstrap/bootstrap.service /etc/systemd/system/
cp -f systemd/bootstrap/bootstrap.socket /etc/systemd/system/
cp -f systemd/bootstrap/bootstrap /etc/sysconfig/bootstrap

#cp -f systemd/dnsmasq/dnsmasq.service /usr/lib/systemd/system/dnsmasq.service



systemctl daemon-reload
systemctl restart docker
systemctl restart bootstrap
systemctl enable bootstrap

