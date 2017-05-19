#!/usr/bin/env bash


BASE_DIR=$(cd `dirname $0` && pwd -P)



#MASTER_IP=${MASTER_IP:-${LOCAL_IP}}


#DIS_URL=${DIS_URL:-"zk://${MASTER0_IP}:2181,${MASTER1_IP}:2181,${MASTER2_IP}:2181/default"}

#HOSTNAME=`hostname`

#docker run -ti --rm \
#        -v ${BASE_DIR}:${BASE_DIR} \
#        -v /var/run/docker.sock:/var/run/docker.sock \
#        -e DOCKER_HOST=unix:///var/run/docker.sock  \
#        -e MASTER0_IP=${MASTER0_IP} \
#        -e MASTER1_IP=${MASTER1_IP} \
#        -e MASTER2_IP=${MASTER2_IP} \
#        -w ${BASE_DIR} \
#        docker/compose:1.9.0 \
#        up -d $*


#MASTER0_IP=${MASTER0_IP} \
#MASTER1_IP=${MASTER1_IP} \
#MASTER2_IP=${MASTER2_IP} \
#DOCKER_HOST=unix:///var/run/docker.sock \
#docker-compose -f ${BASE_DIR}/docker-compose.yml up -d $*


curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.4.0-x86_64.rpm
rpm -vi filebeat-5.4.0-x86_64.rpm

cp filebeat/config/filbeat.yml /etc/filebeat/filebeat.yml
systemctl restart filebeat
systemctl enable filebeat


systemctl status filebeat
/usr/share/filebeat/scripts/import_dashboards -es http://${MASTER0_IP}:9200 -user elastic
