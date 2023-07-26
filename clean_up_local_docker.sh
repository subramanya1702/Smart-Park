#!/bin/bash

function clean_up() {
  echo "Stopping/Removing the containers and images..."
  rm -rf run_dir
  docker stop mongo spclassifier spserver
  docker rm mongo spclassifier spserver
  docker image rm mongo:6.0 spclassifier spserver
  docker network rm smartnetwork
}

clean_up