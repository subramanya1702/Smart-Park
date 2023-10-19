# Smart-Park

## Overview

This work is based
on [Sriranga Chaitanya Nandam's Master's Project](https://research.engr.oregonstate.edu/si-lab/#archive):

* [PDF](https://research.engr.oregonstate.edu/si-lab/archive/2022_chaitanya.pdf)
* [Github](https://github.com/NSR9/Smart-Park)

Ingress and egress pipelines developed by Chaitanya, have undergone modifications to enhance their performance and
scalability. The ingress pipeline, i.e. the ML classifier has been refactored to insert data into a MongoDb database and is now
executed as a Docker container. Likewise, the egress pipeline, which was previously hosted on AWS using technologies like Lambda and API Gateway,
has been migrated to a simpler NodeJs application, tasked with fetching data from MongoDb.
Both pipelines, along with the MongoDb, are now bundled and executed as Docker containers.

## Sections

* [Architecture Diagram](#architecture-diagram)
* [Local/Dev Setup](#localdev-setup)
    * [Requirements](#requirements)
    * [Setting up without docker](#setting-up-without-docker)
    * [Setting up with docker](#setting-up-with-docker)
* [Resources](#resources)

## Architecture Diagram

![Architecture_Diagram.png](Smart_Park_Architecture.png)

### Local/Dev setup

This section goes through the steps required to set up smart park locally. For production set up, follow the instruction over here: [Production set up](Production_Setup.md)

Now, let's start by cloning the Smart-Park repository

```sh
git clone https://github.com/subramanya1702/Smart-Park.git
```

#### Setting up without docker

##### Requirements

* Node >= 14.0.0
* Mongodb >= 6.0.0
* Python = 3.9
* Python VirtualEnv

If you choose to set up and run the components with docker, skip to the [next](#setting-up-with-docker) section.

1. Install and run mongodb by following the instructions over [here](https://www.mongodb.com/docs/manual/installation/)
2. Run the installation script `install_local.sh` to install and run ML classifier and NodeJs application

```sh
chmod +x install_local.sh
```

```sh
./install_local.sh
```

3. Login to Mongodb and verify if records are getting inserted into `recentParkingLots` and `parkingLotHistory`
   collections.
4. Visit `http://localhost:8080/parking_lots` and verify if you are getting the proper response.
5. Once you are done testing, hit CTRL+c to exit and stop the processes.

#### Setting up with docker

1. Make sure docker is installed and running. If not, you can install docker
   from [here](https://docs.docker.com/desktop/install/linux-install/)
2. Run the installation script `install_local_with_docker.sh` to build and run all the 3 components as docker containers

```sh
chmod +x install_local_with_docker.sh
```

```sh
./install_local_with_docker.sh
```

3. Login to Mongodb and verify if records are getting inserted into `recentParkingLots` and `parkingLotHistory`
   collections.
4. Visit `http://localhost:8080/parking_lots` and verify if you are getting the proper response.

3. Once you are done testing, clean up the resources by running the clean-up script `clean_up_local_docker.sh`. This
   removes the temp directory and removes all the newly created docker containers.

```sh
chmod +x clean_up_local_docker.sh
```

```sh
./clean_up_local_docker.sh
```

## Resources

* The GitHub repositories for ML classifier and NodeJs application can be found below.
    * [ML classifier](https://github.com/subramanya1702/SmartPark-ML-Classifier)
    * [REST API (Node App)](https://github.com/subramanya1702/SmartPark-REST-API)

* [Install Docker](https://docs.docker.com/engine/install/ubuntu/)
* [Install MongoDb](https://www.mongodb.com/docs/manual/installation/)
* [OSU Box folder](https://oregonstate.box.com/s/5k8fr4a0x7d98uzj9wn0gdgz3t8lopcj)

## Contributors

Subramanya Keshavamurthy
