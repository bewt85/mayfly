#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Must be run as root" 
  exit 1
fi

if [[ ! -z $DOCKER_ACCOUNT_NAME ]]; then
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

echo "Starting DNS"
CID=$(docker run -d --name dnsmasq -t ${DOCKER_ACCOUNT_NAME}/dnsmasq)

DNS_IP=`docker inspect dnsmasq | awk -F '"' '/IPAddress/ {print $4}'`
HOST_IP=`ifconfig eth0 | awk '/inet addr/ {print $2}' | cut -d: -f2`

echo "Registering services with DNS"
CID=$(docker run -i --rm --volumes-from dnsmasq ${DOCKER_ACCOUNT_NAME}/dnsmasq_updater update frontend.service "$HOST_IP" backend.service "$HOST_IP")

echo "Starting HAProxy"
CID=$(docker run -d --name haproxy       -p 80:80                  --dns $DNS_IP ${DOCKER_ACCOUNT_NAME}/haproxy)
echo "Starting etcd"
CID=$(docker run -d --name etcd-node1 -t -p 7000:7000 -p 9000:9000 --dns $DNS_IP coreos/etcd     -peer-addr ${HOST_IP}:7000 -addr ${HOST_IP}:9000)

WAIT=30s
echo "Giving etcd $WAIT to warm up"
sleep $WAIT

echo "Starting HAProxy config"
CID=$(docker run -d --volumes-from haproxy --name haproxy_updater -e "ETCD_PEERS=${HOST_IP}:9000" ${DOCKER_ACCOUNT_NAME}/haproxy_updater etcdctl --peers ${HOST_IP}:9000 exec-watch --recursive /mayfly -- bash -c "configure_haproxy.py update")

announce $(register $(run backend  0.0.1))
announce $(register $(run backend  0.0.1))
announce $(register $(run backend  0.0.1))
announce $(register $(run frontend 0.0.1))
announce $(register $(run backend  0.0.2))
announce $(register $(run backend  0.0.2))
announce $(register $(run frontend 0.0.2))

echo "Starting HAProxy config updates"
CID=$(docker run -d -t --name environment_registrar -e 'ETCD_PEERS=10.0.2.15:9000' ${DOCKER_ACCOUNT_NAME}/environment_registrar start_auto_update.sh)
CID=$(cat mayfly-environment-registrar/example_config/prod-example.yaml | sudo docker run --rm -i -t --volumes-from environment_registrar -a stdin ubuntu tee /etc/mayfly/environments/prod.yaml)
