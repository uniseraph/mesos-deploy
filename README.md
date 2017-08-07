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

如果是阿里VPC网络，并且VM的内网ip在192.168.0.0/16网段，则需设置环境变量FLANNEL_NETWORK=172.16.0.0/12，否则可以忽略。

```
export FLANNEL_NETWORK=172.16.0.0/12
```


### 初始化 master 相关服务

```
cd /opt/mesos-deploy && MASTER0_IP=xxxx MASTER1_IP=xxxx MASTER2_IP=xxxx PROVIDER=aliyun API_SERVER=tcp://xxxx:8080 bash -x setup-master.sh   --type=swarm

```

以上IP均为VM的内网IP。
注意：由于三台master需要互相组网，所以以上命令请在三台机器上并发执行。



### 初始化 worker相关服务

```
export MASTER0_IP=xxxx
export MASTER1_IP=xxxx
export MASTER2_IP=xxxx
export PROVIDER=aliyun
cd /opt/mesos-deploy && bash setup-worker.sh
```

## 其他

### bridge container ping host
在阿里云经典网络中，阿里云会对VM发出的icmp包进行源mac/源ip校验，所以如果是以bridge模式启动的容器ping宿主机不通。

VPC不存在类似问题。
