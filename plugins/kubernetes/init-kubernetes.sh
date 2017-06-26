#!/usr/bin/env bash



CUR_DIR=`pwd`

rm -rf /tmp/kubernetes
mkdir /tmp/kubernetes
cd /tmp/kubernetes

wget https://github.com/kubernetes/kubernetes/releases/download/v1.6.3/kubernetes.tar.gz
tar zxvf kubernetes.tar.gz
cd kubernetes && ./cluster/get-kube-binaries.sh
cd server
tar xvf kubernetes-server-linux-amd64.tar.gz

cp kubernetes/server/bin/kube-apiserver  /usr/bin
cp kubernetes/server/bin/kube-sheduler  /usr/bin
cp kubernetes/server/bin/kube-controller-manager  /usr/bin
cp kubernetes/server/bin/kube-proxy  /usr/bin

cp kubernetes/server/bin/kubelet /usr/bin
cp kubernetes/server/bin/kubectl /usr/bin



cd ${CUR_DIR}

mkdir -p /etc/kubernetes
cp systemd/kubernetes/etc/* /etc/kubernetes/
cp systemd/kubernetes/service/* /usr/lib/systemd/system/