#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Must be run as root" 
  exit 1
fi

if [[ -z $DOCKER_ACCOUNT_NAME ]]; then
  DOCKER_ACCOUNT_NAME="bewt85"
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
  CID=$(docker run -d -t -p 8080 --dns $DNS_IP ${DOCKER_ACCOUNT_NAME}/${SERVICE}:${VERSION})
  echo $SERVICE $VERSION $CID
}

register() {
  SERVICE=$1
  VERSION=$2
  CID=$3
  PORT=$(docker inspect $CID | ./scripts/extract_docker_port.py 8080)
  CID=$(docker run -d -t ${DOCKER_ACCOUNT_NAME}/container_registrar register ${SERVICE}.service $VERSION $HOST_IP $PORT --peer $HOST_IP:9000)
  echo $SERVICE $VERSION $PORT
}

DNS_IP=`docker inspect dnsmasq | awk -F '"' '/IPAddress/ {print $4}'`
HOST_IP=`ifconfig eth0 | awk '/inet addr/ {print $2}' | cut -d: -f2`

echo "Add some more versions of the apps:"

announce $(register $(run backend  0.0.2))
announce $(register $(run backend  0.0.2))
announce $(register $(run frontend 0.0.2))

echo
echo "Now create a dev environment, copy this:"
echo
cat mayfly-environment-registrar/example_config/dev-example.yaml
echo
echo "Into here"
echo 'sudo docker run -i -t --rm --volumes-from environment_registrar ubuntu vi /etc/mayfly/environments/dev.yaml'
echo
echo 'Also create a qa environment'
echo 'sudo docker run -i -t --rm --volumes-from environment_registrar ubuntu vi /etc/mayfly/environments/qa.yaml'
echo
echo "<Press Enter>"
read -s

./demo/performanceTest.sh
