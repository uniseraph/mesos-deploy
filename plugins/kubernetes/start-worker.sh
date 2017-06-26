#!/usr/bin/env bash





sh init-kubernetes.sh

systemctl enable   kubelet kube-proxy
systemctl restart  kubelet kube-proxy