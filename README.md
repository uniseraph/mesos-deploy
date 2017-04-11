# mesos-deploy

This is a repository of community maintained Mesos cluster deployment
automations.


## 架构

Here's a diagram of what the final result will look like:
![Mesos Single Master Node on Docker](mesos.png)

## 创建一个mesos集群

在阿里云上创建三台centos7u2的虚拟机，每台都是master兼作worker。


### 准备工作

在所有机器上执行如下命令 ，安装git和mesos-deploy

```
yum install -y git && cd /opt && git clone https://github.com/uniseraph/mesos-deploy.git && cd mesos-deploy 

```

### 初始化flannel网络端
如果是阿里云vpc网络，vm的ip端在192.168.0.0/16，则设置FLANNEL_NETWORK=172.16.0.0/12,否则可以忽略。

```
export FLANNEL_NETWORK=172.16.0.0/12
```


### 初始化 master 相关服务
```
export MASTER0_IP=xxxx
export MASTER1_IP=xxxx
export MASTER2_IP=xxxx
cd /opt/mesos-deploy && bash setup-master.sh

```







### 初始化 worker相关服务
```

export MASTER0_IP=xxxx
export MASTER1_IP=xxxx
export MASTER2_IP=xxxx
cd /opt/mesos-deploy && bash setup-worker.sh

```

先指定MASTER_IP ，这样worker可以知道master在那里。





## 
