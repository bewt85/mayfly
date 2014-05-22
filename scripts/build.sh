#!/bin/bash

docker build -t bewt85/frontend      frontend/
docker build -t bewt85/backend       backend/
docker build -t bewt85/dnsmasq       dnsmasq/
docker build -t bewt85/configure_dns configure_dns/