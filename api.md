
Zane Pool API v1.0.0

# Overview
ZanePool根据pool driver不同，有swarm/k8s等多种实现，其中pool管控部分接口是统一的，对pool操作的接口是不同的。


# Endpoints

## Pools
### List pools

### Register a pool
注册一个已经存在的pool
```
POST /pools/register 
```
Example request
```
POST /pools/create HTTP/1.1
Content-Type: application/json

{
       "Name": "xxx",
       "Driver": "swarm",
       "DriverVersion"" "1.0.0",
       "Endpoint": "x.x.x.x:2375",
       "Status": "normal",
       "Nodes": [
       ],
       "Labels": {

       }
  }
```

已经存在的pool，则通过registorPool接口注册到系统中，pool的具体信息通过调用pool的接口去pool中查询，不需要在接口的json中提供。

查询时根据Driver不同，调用不同的接口，如果后端是swarm集群，则调用swarm的docker info接口查询；如果是k8s pool，则调用kubctl cluster-info查询。

所有扩展属性通过label体现。

暂时不提供https/tls pool的访问方式。



### Create a pool
TODO

### Inspect a pool
返回pool的详细信息，数据源部分来自mongodb，部分来自线上集群。
GET /pools/{id}/inspect

Example request
```
GET /pools/4fa6e0f0c678/inspect
```
Example response:
```
HTTP/1.1 200 OK
Content-Type: application/json

{
    
     "Created": "2015-01-06T15:47:31.485331387Z",
     "Driver": "swarm",
     "Name": "xxx",
     "Driver": "swarm",
     "DriverVersion"" "1.0.0",
     "Endpoint": "x.x.x.x:2375",
     "Status": "normal",
     "Nodes": [
          { 
           "Host": "kvm1",
           "Uri": "xxxx:2376",
           "kvm1": "10.173.162.72:2376",
           "ID": "6RFS:DK6J:WO6L:RJOM:CCDC:DB7N:SV45:MCUW:6RLO:HBRB:2ABI:2LGA"
           "Status": "Healthy"
           "Containers": "14 (12 Running, 0 Paused, 2 Stopped)"
           "Reserved CPUs": "0 / 4"
           "Reserved Memory": "0 B / 3.887 GiB"
           "Labels":
             [ "kernelversion":"3.10.0-327.36.3.el7.x86_64", 
               "operatingsystem=CentOS Linux 7 (Core)", 
               "storagedriver=devicemapper" ] ,
           UpdatedAt: 2017-05-25T03:13:41Z
           ServerVersion: 1.12.6
           },
           /...
      ],
     "Labels": {
         "Security Options:
         "Kernel Version": "3.10.0-327.36.3.el7.x86_64"
         "Operating System": "linux"
         "Architecture": "amd64"
         "CPUs": "8"
         "Total Memory": "7.775 GiB",
         "IPs": "", //flannel模式下意义不大，ip不是珍稀资源
     }
    }
```
### Get pool logs

### 

## Nodes

### List Nodes
### Import a node to pool
### 

## Containers

## Images

## Misc

## Volumes

## Networks
