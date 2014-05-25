#!/bin/bash

HOST_IP=`ifconfig eth0 | awk '/inet addr/ {print $2}' | cut -d: -f2`

docker run -d --name dnsmasq   -t                           bewt85/dnsmasq

DNS_IP=`docker inspect dnsmasq | awk -F '"' '/IPAddress/ {print $4}'`

docker run -d --name backend  -t -p 5001:8080 --dns $DNS_IP bewt85/backend
docker run -d --name frontend -t -p 5000:8080 --dns $DNS_IP bewt85/frontend
docker run -d --name haproxy  -t -p 80:80     --dns $DNS_IP bewt85/haproxy

docker run -i --rm --volumes-from dnsmasq bewt85/configure_dns update frontend.service "$HOST_IP" backend.service "$HOST_IP" 
# docker run -i --rm --volumes-from haproxy -t bewt85/configure_haproxy
