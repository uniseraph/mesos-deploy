#!/usr/bin/env bash


if [[ -z ${MASTER_IP} ]]; then
    echo "Please export MASTER0_IP in your env"
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
    bash -x start-bootstrap.sh  dnsmasq flanneld consul-agent  && \
    bash -x start-docker.sh



if [[ ${TYPE} == "mesos" ]]; then
    bash -x start-mesos.sh  slave
elif [[ ${TYPE} == "swarm" ]]; then
    export DIS_URL="consul://127.0.0.1:8500/default"

    bash -x plugins/swarm/start.sh agent
    bash -x plugins/watchdog/start.sh

else
    echo  "No such cluster type:${TYPE}"
    exit -1
fi






