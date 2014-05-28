#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Must be run as root" 
  exit 1
fi

docker build -t bewt85/frontend:0.0.2    frontend/
docker build -t bewt85/backend:0.0.2     backend/
docker build -t bewt85/dnsmasq           dnsmasq/
docker build -t bewt85/configure_dns     configure_dns/
docker build -t bewt85/haproxy           haproxy/
docker build -t bewt85/configure_haproxy configure_haproxy/
docker build -t bewt85/etcdctl:0.4.1     etcdctl/
docker build -t bewt85/service_registrar service_registrar/


