## 创建一个Docker集群

在阿里云上创建三台centos7u2的虚拟机，每台都是master兼作worker。



### 准备工作

在所有机器上执行如下命令，安装git和mesos-deploy

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
cd /opt/mesos-deploy && MASTER0_IP=xxxx MASTER1_IP=xxxx MASTER2_IP=xxxx PROVIDER=aliyun API_SERVER=tcp://xxxx:8080 bash -x setup-master.sh  --type=swarm
```

以上MASTERx_IP均为VM的内网IP，API_SERVER的IP是公网IP（如果Docker集群与API服务器在同一个集群，则也可以使用私网IP）。

注意：由于三台master需要互相组网，所以以上命令请在三台机器上并发执行。



### 初始化 worker相关服务

```
export MASTER0_IP=xxxx
export MASTER1_IP=xxxx
export MASTER2_IP=xxxx
export PROVIDER=aliyun
cd /opt/mesos-deploy && bash setup-worker.sh
```

以上MASTERx_IP均为VM的内网IP。

如果集群中只有master没有worker，此步骤忽略。



## 安全策略

### 出方向

节点需要访问公网，有两种方式配置节点出公网：

（1）如果节点数较少，建议每个节点直接分配一个公网IP；

（2）如果节点数很多，不能做到每个节点一个公网IP，建议配置SNAT网关；

### 入方向

入方向需要严格的权限控制，以免发生安全事故。

#### 定向给API服务器授权

（1）2375端口：管理API端口；

（2）6400端口：元数据管理端口；

如果API服务器与master节点在同一个集群，则不需要做API定向授权。

#### 特定服务定向授权

（1）2022端口：SSH服务端口。建议只给指定IP（比如跳板机）授权。



## 其他

### bridge container ping host
在阿里云经典网络中，阿里云会对VM发出的icmp包进行源mac/源ip校验，所以如果是以bridge模式启动的容器ping宿主机不通。

VPC不存在类似问题。
