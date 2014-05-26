#!/bin/bash

# User within register_service to kill the container if the key it is updating 
# is deleted (e.g. by another container killing the service).
set -e

usage() {
  echo "Usage:"
  echo "$0 register   <service> <version> <host name or ip> <port> [ --peer <etcd peer> ] # Registers a service with etcd"
  echo "$0 deregister <service> <version> <host name or ip> <port> [ --peer <etcd peer> ] # Deregisters a service with etcd"
  echo "$0 list       <service> [ <version> ] [ --peer <etcd peer> ]                      # Lists 'host:port' for a service"
}

etcd(){
  etcdctl $ETCD_PEERS $@
}

service_dir(){
  echo "/mayfly/backends/$SERVICE/$VERSION"
}

list() {
  for key in $(etcd ls $SERVICE_DIR); do
    SERVICE_LOCATION=$(etcd get $key)
    echo "$SERVICE $VERSION $SERVICE_LOCATION"
  done
}

list_all_versions() {
  VERSION=""
  VERSION_DIRS=$(service_dir)
  for SERVICE_DIR in $(etcd ls $VERSION_DIRS); do
    VERSION=$(echo $SERVICE_DIR | awk -F/ '{print $NF}')
    SERVICE_DIR=$(service_dir)
    list
  done
}

register_service() {
  UUID=$(cat /proc/sys/kernel/random/uuid)
  etcd ls "$SERVICE_DIR" || etcd setdir "$SERVICE_DIR"
  etcd set "$SERVICE_DIR/$UUID" "$SERVICE_LOCATION" --ttl 60
  sleep 45s
  while true; do
    etcd set "$SERVICE_DIR/$UUID" "$SERVICE_LOCATION" --swap-with-value "$SERVICE_LOCATION" --ttl 60
    sleep 45s
  done
}

deregister_service() {
  for key in $(etcd ls $SERVICE_DIR); do
    etcd rm $key --with-value "$SERVICE_LOCATION"
  done
}

COMMAND=$1
SERVICE=$2
VERSION=$3
SERVICE_DIR=$(service_dir)

if [[ 'list' == $COMMAND ]]; then
  if [[ $# == 2 ]]; then
    # list foo
    ETCD_PEERS=""
    list_all_versions
  elif [[ $# == 3 ]]; then
    # list foo 1.0.0
    ETCD_PEERS=""
    list
  elif [[ $# == 4 && '--peer' == $3 ]]; then
    # list foo --peer 127.0.0.1:4000
    ETCD_PEERS="--peers $4"
    list_all_versions
  elif [[ $# == 5 && '--peer' == $4 ]]; then
    # list foo 1.0.0 --peer 127.0.0.1:4000
    ETCD_PEERS="--peers $5"
    list
  else
    usage
    exit 1
  fi
  exit 0
elif [[ $# == 5 ]]; then
  ETCD_PEERS=""
elif [[ $# == 7 ]]; then
  ETCD_PEERS="--peers $7"
else
  usage
  exit 1
fi

HOST=$4
PORT=$5
SERVICE_LOCATION="$HOST:$PORT"

if [[ 'register' == $COMMAND ]]; then
  register_service
elif [[ 'deregister' == $COMMAND ]]; then
  deregister_service
else
  usage
  exit 1
fi
