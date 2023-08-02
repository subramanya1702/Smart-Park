#!/bin/bash

function clean_up() {
  echo "Stopping/Removing the containers and images..."
  rm -rf run_dir
  docker stop mongo spclassifier sprestapi
  docker rm mongo spclassifier sprestapi
  docker image rm mongo:6.0 spclassifier sprestapi
  docker network rm smartnetwork
}

clean_up