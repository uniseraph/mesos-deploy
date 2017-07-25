#!/usr/bin/env bash


if [[ -z ${MASTER0_IP} ]]; then
    echo "Please export MASTER0_IP in your env"
    exit 1
fi

if [[ -z ${MASTER1_IP} ]]; then
    echo "Please export MASTER1_IP in your env"
    exit 1
fi

if [[ -z ${MASTER2_IP} ]]; then
    echo "Please export MASTER2_IP in your env"
    exit 1
fi


TYPE=mesos
WITH_CADVISOR=false
WITH_HDFS=false
WITH_YARN=false
WITH_ELK=false
WITH_EBK=false

ARGS=`getopt -a -o T: -l type:,with-cadvisor,with-yarn,with-elk,with-ebk,with-hdfs,help -- "$@" `
[ $? -ne 0 ] && usage
#set -- "${ARGS}"
eval set -- "${ARGS}"
while true
do
        case "$1" in
        -T|--type)
                TYPE="$2"
                shift
                ;;
        --with-cadvisor)
                WITH_CADVISOR=true
                ;;
        --with-hdfs)
                WITH_HDFS=true
                ;;
        --with-elk)
                WITH_ELK=true
                ;;
        --with-ebk)
                WITH_EBK=true
                ;;
        --with-yarn)
                WITH_YARN=true
                ;;
        -h|--help)
                usage
                ;;
        --)
                shift
                break
                ;;
        esac
shift
done


echo "TYPE=${TYPE}"
echo "WITH_CADVISOR=${WITH_CADVISOR}"
echo "WITH_YARN=${WITH_YARN}"
echo "WITH_HDFS=${WITH_HDFS}"
echo "WITH_ELK=${WITH_ELK}"
echo "WITH_ELK=${WITH_EBK}"


bash -x init-node.sh

if [[ ${TYPE} == "mesos" ]]; then

    bash -x start-bootstrap.sh  etcd zookeeper dnsmasq flanneld consul-server  && \
    bash -x start-docker.sh

    bash -x start-mesos.sh master slave

    LOCAL_IP=$(ifconfig eth0 | grep inet\ addr | awk '{print $2}' | awk -F: '{print $2}')

    if [[ ${LOCAL_IP} == ${MASTER0_IP} ]]; then
        bash -x start-mesos.sh marathon mesos-consul
        echo "marathon starting success ......, Please access http://${LOCAL_IP}:8080"
    fi
elif [[ ${TYPE} == "swarm" ]]; then
    bash -x start-bootstrap.sh  etcd  dnsmasq flanneld consul-server  && \
    bash -x start-docker.sh

    bash -x plugins/watchdog/start.sh
    bash -x plugins/metad/start.sh
    bash -x plugins/tunneld/start.sh

    DIS_URL="consul://127.0.0.1:8500/default" bash -x plugins/swarm/start.sh  master agent

elif [[ ${TYPE} == "kubernetes" ]]; then
    bash -x start-bootstrap.sh  etcd  dnsmasq flanneld consul-server  && \
    bash -x start-docker.sh

  #   bash -x plugins/kubernetes/init-kubernetes.sh
  #  bash -x plugins/kubernetes/start-master.sh
  #  bash -x plugins/kubernetes/start-worker.sh

else
    echo  "No such cluster type:${TYPE}"
    exit -1
fi


if [[ ${WITH_ELK} == true ]]; then
    bash -x plugins/elk/start.sh logspout logstash  kibana elasticsearch
fi

if [[ ${WITH_EBK} == true ]]; then
    bash -x plugins/elk/start.sh  kibana elasticsearch
    bash -x plugins/beats/start.sh
fi
