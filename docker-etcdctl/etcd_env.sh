#!/bin/bash

extras=""

if [[ ! -z $ETCD_PEERS ]]; then
  extras="--peers $ETCD_PEERS $extras"
fi

etcdctl $(echo "$extras $@")
