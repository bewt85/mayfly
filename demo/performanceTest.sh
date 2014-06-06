#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Must be run as root" 
  exit 1
fi

announce() {
  SERVICE=$1
  VERSION=$2
  PORT=$3
  echo "Started ${SERVICE}.service_${VERSION} on port $PORT"
}

run() {
  SERVICE=$1
  VERSION=$2
  CID=$(docker run -d -t -p 8080 --dns $DNS_IP bewt85/${SERVICE}:${VERSION})
  echo $SERVICE $VERSION $CID
}

register() {
  SERVICE=$1
  VERSION=$2
  CID=$3
  PORT=$(docker inspect $CID | ./scripts/extract_docker_port.py 8080)
  CID=$(docker run -d -t bewt85/service_registrar register ${SERVICE}.service $VERSION $HOST_IP $PORT --peer $HOST_IP:9000)
  echo $SERVICE $VERSION $PORT
}

DNS_IP=`docker inspect dnsmasq | awk -F '"' '/IPAddress/ {print $4}'`
HOST_IP=`ifconfig eth0 | awk '/inet addr/ {print $2}' | cut -d: -f2`

echo 'We can also show that there is zero downtime (only milli blips)'
echo "Open this in another tab, change it but don't save"
echo 'sudo docker run -i -t --rm --volumes-from frontend_registrar ubuntu vi /etc/mayfly/environments/prod.yaml'
echo
echo "When you're ready, <Press Enter> to start the siege.  You have 30 seconds to save the updated prod config"
read -s
echo
siege www.example.com
echo
echo "Note the change in file size shows when the change occured"
