#!/usr/bin/env bash



systemctl enable kube-apiserver kube-controller-manager kube-scheduler kubelet
systemctl restart kube-apiserver kube-controller-manager kube-scheduler kubelet