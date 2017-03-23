# mesos-deploy

This is a repository of community maintained Mesos cluster deployment
automations.


## 架构

Here's a diagram of what the final result will look like:
![Mesos Single Master Node on Docker](mesos.png)

## 创建一个mesos集群

在阿里云上创建两个centos7u2的虚拟机，其中一台是master兼作worker，另一台是worker。


## 准备工作

在所有机器上执行如下命令 ，安装git和mesos-deploy

```
yum install -y git && cd /opt && git clone https://github.com/uniseraph/mesos-deploy.git

```

## 初始化节点

```
cd /opt/mesos-deploy && bash init-node.sh

```


## 初始化 master 相关服务


### 
```
export HOST_IP=xxxxx

```


## 初始化mesos slave 相关服务