#!/usr/bin/env bash
BASE_DIR=$(cd `dirname $0` && pwd -P)

if type dpkg >/dev/null 2>&1; then
    curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-5.5.1-amd64.deb
    sudo dpkg -i metricbeat-5.5.1-amd64.deb  &&  rm -f metricbeat-5.5.1-amd64.deb
    curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.5.1-amd64.deb
    sudo dpkg -i filebeat-5.5.1-amd64.deb && rm -f  filebeat-5.5.1-amd64.deb
elif type rpm >/dev/null 2>&1; then
    curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-5.5.1-x86_64.rpm
    sudo rpm -vi metricbeat-5.5.1-x86_64.rpm  && rm -rf  metricbeat-5.5.1-x86_64.rpm
    curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.4.0-x86_64.rpm
    rpm -vi filebeat-5.4.0-x86_64.rpm && rm -rf filebeat-5.4.0-x86_64.rpm
else
    echo "no dpkg and no yum"
    exit
fi

cp ${BASE_DIR}/filebeat/config/filebeat.yml /etc/filebeat/filebeat.yml
sed -i -e "s#master0#${MASTER0_IP}#g" /etc/filebeat/filebeat.yml
sed -i -e "s#master1#${MASTER1_IP}#g" /etc/filebeat/filebeat.yml
sed -i -e "s#master2#${MASTER2_IP}#g" /etc/filebeat/filebeat.yml
systemctl restart filebeat
systemctl enable filebeat
systemctl status filebeat
/usr/share/filebeat/scripts/import_dashboards -es http://${MASTER0_IP}:9200 -user elastic



cp ${BASE_DIR}/metricbeat/config/metricbeat.yml /etc/metricbeat/metricbeat.yml
sed -i -e "s#master0#${MASTER0_IP}#g" /etc/metricbeat/metricbeat.yml
sed -i -e "s#master1#${MASTER1_IP}#g" /etc/metricbeat/metricbeat.yml
sed -i -e "s#master2#${MASTER2_IP}#g" /etc/metricbeat/metricbeat.yml
systemctl restart metricbeat
systemctl enable metricbeat
systemctl status metricbeat
/usr/share/metricbeat/scripts/import_dashboards -es http://${MASTER0_IP}:9200 -user elastic
