#!/bin/bash

# Validate if docker is installed and running
function validate_docker() {
  if command -v docker &>/dev/null; then
    if docker info &>/dev/null; then
      echo "Docker is installed and running"
    else
      echo "Docker is not running. Please start docker to proceed"
      exit 1
    fi
  else
    echo "Docker is not installed. Please install docker to proceed"
    exit 1
  fi
}

# Create a docker network
function create_network() {
  docker network create smartnetwork
}

# Run MongoDb
function run_mongodb() {
  docker pull mongo:6.0
  docker run -dp 27017:27017 --network smartnetwork --name mongo mongo:6.0
}

# Run ML classifier
function run_classifier() {
  # Clone the repository
  git clone https://github.com/subramanya1702/SmartPark-ML-Classifier.git

  # Navigate to smart_park directory
  # shellcheck disable=SC2164
  cd SmartPark-ML-Classifier/smart_park

  # Download pytorch file
  curl -L -O https://github.com/VilledeMontreal/urban-detection/releases/download/v0.1-alpha/X-512.pt

  docker build -t spclassifier .
  docker run -d --env DB_CONN_STR=mongo:27017 --network smartnetwork --name spclassifier spclassifier
}

# Run NodeJs application
function run_node_app() {
  # Clone the repository
  git clone https://github.com/subramanya1702/SmartPark-REST-API.git

  # Navigate to SmartPark-REST-API directory
  # shellcheck disable=SC2164
  cd SmartPark-REST-API

  docker build -t sprestapi .
  docker run -dp 8080:8080 --env DB_CONN_STR=mongo:27017 --network smartnetwork --name sprestapi sprestapi
}

function install() {
  rm -rf run_dir
  mkdir run_dir
  # shellcheck disable=SC2164
  cd run_dir
  rpwd=$PWD

  create_network
  run_mongodb
  run_classifier
  # shellcheck disable=SC2164
  cd "$rpwd"
  run_node_app
  # shellcheck disable=SC2164
  cd "$rpwd"
}

validate_docker
install
