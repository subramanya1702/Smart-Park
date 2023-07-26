#!/bin/bash

# Validate requirements
function validate_requirements() {
  # Validate if the correct node js version is installed
  if command -v node &>/dev/null; then
    node_version=$(node --version)
    major_version=$(echo "$node_version" | cut -d'v' -f2 | cut -d'.' -f1)

    # Check if the major version is 14 or greater
    if [ "$major_version" -ge 14 ]; then
      echo "Node.js is installed and the version is greater than or equal to 14.x.x"
    else
      echo "Node.js version is below 14.x.x. Please install Node.js version 14.x.x or higher to proceed."
      exit 1
    fi
  else
    echo "Node.js is not installed. Please install Node.js version 14.x.x or higher to proceed."
    exit 1
  fi

  # Validate if mongodb is installed and running
  if command -v mongosh &>/dev/null; then
    if pgrep -x "mongod" >/dev/null; then
      echo "MongoDb is running."
    else
      echo "MongoDb is not running. Please start MongoDb to proceed."
      exit 1
    fi
  else
    echo "MongoDb is not installed. Please install MongoDb to proceed."
    exit 1
  fi

  # Validate if the correct version of python is installed
  if command -v python3.9 &>/dev/null; then
    python_version=$(python3.9 --version)
    if [[ $python_version == *"Python 3.9"* ]]; then
      echo "Python 3.9 is installed"
    else
      echo "Python 3.9 is not installed. Please install Python 3.9 to proceed."
      exit 1
    fi
  else
    echo "Python 3.9 is not installed. Please install Python 3.9 to proceed."
    exit 1
  fi

  # Install if python virtualenv is installed
  if command -v virtualenv &>/dev/null; then
    virtual_env__version=$(virtualenv --version)
    echo "Python virtualenv is installed. Version: $virtual_env__version"
  else
    echo "Python virtualenv is not installed. Please install python virtualenv to proceed."
    exit 1
  fi
}

python_pid=1
node_pid=1

# Set up ML classifier
function set_up_classifier() {
  echo
  echo

  # Clone the repository
  git clone https://github.com/subramanya1702/Smart-Park-Reboot.git

  # Navigate to smart_park directory
  # shellcheck disable=SC2164
  cd Smart-Park-Reboot/smart_park

  # Create and activate a virtual environment
  python -m venv env
  source env/bin/activate

  # Install dependencies
  pip install -r requirements.txt

  # Copy activation.py file to the torch modules directory
  cp activation.py env/lib/python3.9/site-packages/torch/nn/modules/

  # Download pytorch file
  curl -L -O https://github.com/VilledeMontreal/urban-detection/releases/download/v0.1-alpha/X-512.pt

  # Run the classifier
  python run_process1.py &

  # Capture PID
  python_pid=$!
  echo "Python PID: $python_pid"
}

# Set up NodeJs application
function set_up_node_app() {
  echo
  echo

  # Clone the repository
  git clone https://github.com/subramanya1702/Smart-Park-Server.git

  # Navigate to Smart-Park-Server directory
  # shellcheck disable=SC2164
  cd Smart-Park-Server

  # Install dependencies
  npm install

  # Run the application in dev mode
  npm run start:dev &

  # Capture PID
  node_pid=$!
  echo "Node PID: $node_pid"
}

# Stop/Kill classifier and node processes
function stop_processes() {
  echo
  echo
  echo "Stopping processes..."
  cd ..
  kill $python_pid
  kill $node_pid
  sleep 5
  rm -rf run_dir
}

# Trap SIGINT signal (Ctrl + C) and call the stop_processes function
trap stop_processes SIGINT

function install() {
  rm -rf run_dir
  mkdir run_dir
  # shellcheck disable=SC2164
  cd run_dir
  rpwd=$PWD

  set_up_classifier
  # shellcheck disable=SC2164
  cd "$rpwd"
  set_up_node_app
  # shellcheck disable=SC2164
  cd "$rpwd"
}

validate_requirements
install

# Wait for both processes to finish
wait $python_pid
wait $node_pid
