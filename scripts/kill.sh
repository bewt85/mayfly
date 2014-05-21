#!/bin/bash

docker_kill () {
  REMOVE=$1
  shift 1
  while [[ $# -ge 3 ]]; do
    CONTAINER_ID=$1
    CONTAINER_IMAGE=$2
    CONTAINER_NAME=$3
    shift 3
    docker kill $CONTAINER_ID > /dev/null
    if [[ $? == 0 ]]; then
      echo "Killed $CONTAINER_NAME ($CONTAINER_ID) based on image $CONTAINER_IMAGE"
      if [[ $REMOVE == true ]]; then
        docker rm $CONTAINER_ID > /dev/null
        if [[ $? == 0 ]]; then
          echo "Deleted $CONTAINER_NAME ($CONTAINER_ID) based on image $CONTAINER_IMAGE"
        else
          echo "Failed to delete $CONTAINER_NAME ($CONTAINER_ID) based on image $CONTAINER_IMAGE" >&2
          exit 1
        fi
      fi
    else
      echo "Failed to kill $CONTAINER_NAME ($CONTAINER_ID) based on image $CONTAINER_IMAGE" >&2
      exit 1
    fi
  done
}

container_details=`docker ps | awk '!/^CONTAINER\s*/ {print $1, $2, $NF}'`
if [[ $1 == --rm ]]; then
  REMOVE=true
else
  REMOVE=false
fi
docker_kill $REMOVE $container_details
