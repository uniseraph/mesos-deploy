#!/usr/bin/env bash



systemctl enable kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy
systemctl restart kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy