#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Must be run as root" 
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname $0 )" && pwd )"

cd ${SCRIPT_DIR}/..
demo-services/example-frontend/build.sh
demo-services/example-backend/build.sh

docker build -t bewt85/dnsmasq           dnsmasq/
docker build -t bewt85/configure_dns     configure_dns/
docker build -t bewt85/haproxy           haproxy/
docker build -t bewt85/configure_haproxy configure_haproxy/
docker build -t bewt85/etcdctl:0.4.1     etcdctl/
docker build -t bewt85/service_registrar service_registrar/


