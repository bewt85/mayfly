#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Must be run as root" 
  exit 1
fi

run() {
  SERVICE=$1
  VERSION=$2
  echo "Starting ${SERVICE}.service_${VERSION}" >&2
  CID=$(docker run -d --name ${SERVICE}_${VERSION} -t -p 8080 --dns $DNS_IP bewt85/${SERVICE}:${VERSION})
  echo $CID
}

register() {
  SERVICE=$1
  VERSION=$2
  PORT=$(docker inspect ${SERVICE}_${VERSION} | ./scripts/extract_docker_port.py 8080)
  echo "Registering ${SERVICE}.service_${VERSION} on port $PORT" >&2
  docker run -d -t bewt85/etcd_registrar register ${SERVICE}.service $VERSION $HOST_IP $PORT --peer $HOST_IP:9000
}

docker run -d --name dnsmasq -t bewt85/dnsmasq

DNS_IP=`docker inspect dnsmasq | awk -F '"' '/IPAddress/ {print $4}'`
HOST_IP=`ifconfig eth0 | awk '/inet addr/ {print $2}' | cut -d: -f2`

docker run -i --rm --volumes-from dnsmasq bewt85/configure_dns update frontend.service "$HOST_IP" backend.service "$HOST_IP"

docker run -d --name haproxy       -p 80:80                  --dns $DNS_IP bewt85/haproxy
docker run -d --name etcd-node1 -t -p 7000:7000 -p 9000:9000 --dns $DNS_IP coreos/etcd     -peer-addr ${HOST_IP}:7000 -addr ${HOST_IP}:9000

run       backend  0.0.1; register backend  0.0.1
run       backend  0.0.2; register backend  0.0.2
run       frontend 0.0.1; register frontend 0.0.1
run       frontend 0.0.2; register frontend 0.0.2

docker run -i --rm --volumes-from haproxy -e "ETCD_PEERS=${HOST_IP}:9000" bewt85/configure_haproxy configure_haproxy.py update
