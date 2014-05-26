#!/bin/bash

usage() {
  echo "Usage:"
  echo "$0 link   <service> <version> <host name or ip> <internal docker port> [ --peer <etcd peer> ] # Registers a service with etcd"
  echo "$0 unlink <service> <version> <host name or ip> <internal docker port> [ --peer <etcd peer> ] # Deregisters a service with etcd"
  echo
  echo "Called with:"
  echo "$@"
}

env_variable_key() {
  echo "SERVICE_PORT_${DOCKER_PORT}_TCP_PORT"
}

get_host_port() {
  ENV_KEY=$(env_variable_key)
  docker_port="${!ENV_KEY}"
  echo "$docker_port"
}

COMMAND=$1

if [[ 'list' == $COMMAND ]]; then
  /run.sh $(echo "$@")
  exit 0
elif [[ $# == 7 ]]; then
  if [[ "--peer" != $6 ]]; then
    usage $@
    exit 1
  fi
elif [[ $# != 5 ]]; then
  usage $@
  exit 1
fi

DOCKER_PORT=$5
HOST_PORT=$(get_host_port)

if [[ -z $HOST_PORT ]]; then
  echo "ERROR: Couldn't find host port corresponding to $DOCKER_PORT"
  usage $@
  exit 1
fi

if [[ 'link' == $COMMAND ]]; then
  /run.sh $(echo "register ${@:2:3} $HOST_PORT ${@:6}")
elif [[ 'unlink' == $COMMAND ]]; then
  /run.sh $(echo "deregister ${@:2:3} $HOST_PORT ${@:6}")
else
  usage $@
  exit 1
fi
