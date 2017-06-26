#!/usr/bin/env bash





sh init-kubernetes.sh

systemctl enable   kubelet
systemctl restart  kubelet