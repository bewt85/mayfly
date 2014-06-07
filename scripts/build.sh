#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Must be run as root" 
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname $0 )" && pwd )"

cd ${SCRIPT_DIR}/..
demo-services/example-frontend/build.sh
demo-services/example-backend/build.sh

docker-etcdctl/build.sh
docker-dnsmasq/build.sh
docker-haproxy/build.sh

mayfly-dnmasq-updater/build.sh
mayfly-haproxy-updater/build.sh
mayfly-container-registrar/build.sh
mayfly-environment-registrar/build.sh
