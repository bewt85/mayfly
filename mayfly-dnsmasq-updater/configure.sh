#!/bin/bash

usage() {
  echo "$0 reset                            # Resets DNS to default values"
  echo "$0 list                             # Lists config"
  echo "$0 update <host> <ip> [<host> <ip>] # Updates an entry in DNS"
  echo "$0 delete <host> [<host>]           # Removes a host from DNS"
}

update_dns() {
  HOST=$1
  IP=$2
  EXISTING_ENTRY=`grep "$HOST" /etc/dnsmasq/hosts`
  if [[ -z $EXISTING_ENTRY ]]
    then
      echo "$IP $HOST" >> /etc/dnsmasq/hosts
  else
    sed -i "s/^.*$HOST.*$/$IP $HOST/" /etc/dnsmasq/hosts
  fi
}

command=$1
shift 1
if [[ 'reset' == $command ]]
  then
    cat /dev/null >/etc/dnsmasq/hosts 
elif [[ 'list' == $command ]]
  then
    cat /etc/dnsmasq/hosts
elif [[ 'update' == $command ]]
  then
    while [ $# -ne 0 ] 
      do
        HOST=$1
        IP=$2
        if [[ -z $IP || -z $HOST ]]
          then
            break
        fi
        update_dns $HOST $IP 
        shift 2
    done
elif [[ 'delete' == $command ]]
  then
    while [ $# -ne 0 ]
      do
        HOST=$1
        sed -i "/^.*$HOST.*$/d" /etc/dnsmasq/hosts 
        shift 1
    done
else
  usage
  exit 1
fi
