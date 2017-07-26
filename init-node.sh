#!/usr/bin/env bash

echo "net.ipv4.etc.eth0.rp_filter=0" > /etc/sysctl.d/omega.conf

sysctl -w net.ipv4.conf.eth0.rp_filter=0
sysctl -w vm.max_map_count=262144

cp sysctl.conf /etc/sysctl.conf
sysctl -p

if type apt-get >/dev/null 2>&1; then
  echo 'using apt-get '
  sudo apt-get update && apt-get install -y jq  bridge-utils tcpdump  haveged strace pstack htop  curl wget  iotop blktrace   dstat ltrace lsof
  export LOCAL_IP=$(ifconfig eth0 | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}')

elif type yum >/dev/nul 2>&1; then
  echo 'using yum'
  sudo yum install -y  jq bind-utils bridge-utils tcpdump dnsmasq haveged strace pstack htop iostat vmstat curl wget sysdig pidstat mpstat iotop blktrace perf  dstat ltrace lsof
  export LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')

else
  echo "no apt-get and no yum, exit"
  exit
fi



rm -rf tmp && mkdir -p tmp && cd tmp
wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-1.11.1 -q  -O docker
wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd -q
wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd-ctr -q
wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-containerd-shim -q
wget http://zanecloud-docker.oss-cn-shanghai.aliyuncs.com/1.11.1/d349391/docker-runc -q

cd ..
sudo chmod +x tmp/*
sudo cp -f  tmp/* /usr/bin/


sudo mkdir -p /etc/sysconfig
cp -f systemd/docker-1.11/docker.service /etc/systemd/system/
cp -f systemd/docker-1.11/docker.socket /etc/systemd/system/

cp -f systemd/bootstrap/bootstrap.service /etc/systemd/system/
cp -f systemd/bootstrap/bootstrap.socket /etc/systemd/system/
cp -f systemd/bootstrap/bootstrap /etc/sysconfig/bootstrap

systemctl daemon-reload
systemctl restart docker
systemctl restart bootstrap
systemctl enable bootstrap

