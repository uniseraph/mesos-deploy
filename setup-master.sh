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

ARGS=`getopt -a -o T: -l type:,with-cadvisor,with-yarn,with-elk,with-hdfs,help -- "$@" `
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




bash -x init-node.sh  && \
    bash -x start-bootstrap.sh  etcd zookeeper dnsmasq flanneld consul-server  && \
    bash -x start-docker.sh

if [[ ${TYPE} == "mesos" ]]; then

    bash -x start-mesos.sh master slave

    LOCAL_IP=$(ifconfig eth0 | grep inet | awk '{{print $2}}')
    if [[ ${LOCAL_IP} == ${MASTER0_IP} ]]; then
        bash -x start-mesos.sh marathon mesos-consul
        echo "marathon starting success ......, Please access http://${LOCAL_IP}:8080"
    fi
elif [[ ${TYPE} == "swarm" ]]; then

    bash -x plugins/swarm/start.sh
    bash -x plugins/watch/start.sh
else
    echo  "No such cluster type:${TYPE}"
    exit -1
fi