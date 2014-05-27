#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Must be run as root" 
  exit 1
fi

HOST_IP=`ifconfig eth0 | awk '/inet addr/ {print $2}' | cut -d: -f2`

docker run -d --name dnsmasq   -t                           bewt85/dnsmasq

DNS_IP=`docker inspect dnsmasq | awk -F '"' '/IPAddress/ {print $4}'`

docker run -d --name haproxy       -p 80:80                  --dns $DNS_IP bewt85/haproxy
docker run -d --name etcd-node1 -t -p 7000:7000 -p 9000:9000 --dns $DNS_IP coreos/etcd     -peer-addr ${HOST_IP}:7000 -addr ${HOST_IP}:9000

docker run -d --name backend_0.0.1  -t -p 6000:8080 --dns $DNS_IP bewt85/backend:0.0.1
docker run -d --name frontend_0.0.1 -t -p 5000:8080 --dns $DNS_IP bewt85/frontend:0.0.1
docker run -d --name backend_0.0.2  -t -p 6001:8080 --dns $DNS_IP bewt85/backend:0.0.2
docker run -d --name frontend_0.0.2 -t -p 5001:8080 --dns $DNS_IP bewt85/frontend:0.0.2

docker run -d -t bewt85/etcd_registrar register backend.service  0.0.1 $HOST_IP 6000 --peer $HOST_IP:9000
docker run -d -t bewt85/etcd_registrar register frontend.service 0.0.1 $HOST_IP 5000 --peer $HOST_IP:9000
docker run -d -t bewt85/etcd_registrar register backend.service  0.0.2 $HOST_IP 6001 --peer $HOST_IP:9000
docker run -d -t bewt85/etcd_registrar register frontend.service 0.0.2 $HOST_IP 5001 --peer $HOST_IP:9000

docker run -i --rm --volumes-from dnsmasq bewt85/configure_dns update frontend.service "$HOST_IP" backend.service "$HOST_IP" 
docker run -i --rm --volumes-from dnsmasq bewt85/configure_dns update host1.internal   "$HOST_IP"
docker run -i --rm --volumes-from haproxy bewt85/configure_haproxy configure_haproxy.py update
