#!/bin/bash

set -e

usage() {
  echo "Usage:"
  echo "$0 register   <service> <version> <host name or ip> <port> [ <etcd peer> ] # Registers a service with etcd"
  echo "$0 deregister <service> <version> <host name or ip> <port> [ <etcd peer> ] # Deregisters a service with etcd"
  echo "$0 list       <service> <version> [ <etcd peer> ]                          # Lists 'host:port' for a service"
}

etcd(){
  etcdctl $ETCD_PEERS $@
}

list() {
  for key in $(etcd ls $SERVICE_DIR); do
    etcd get $key
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
SERVICE_DIR="/mayfly/backends/$SERVICE/$VERSION"

if [[ 'list' == $COMMAND ]]; then
  if [[ $# == 3 ]]; then
    ETCD_PEERS=""
  elif [[ $# == 4 ]]; then
    ETCD_PEERS="--peers $4"
  else
    usage
    exit 1
  fi
elif [[ $# == 5 ]]; then
  ETCD_PEERS=""
elif [[ $# == 6 ]]; then
  ETCD_PEERS="--peers $6"
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
elif [[ 'list' == $COMMAND ]]; then
  list
else
  usage
  exit 1
fi
