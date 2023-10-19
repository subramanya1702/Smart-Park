## Production setup

For setting up the production environment, we assume that all the three components: ML Classifier, REST API and MongoDb will be packaged and run as individual docker containers.

*All the 3 containers should ideally run on different servers so that it doesn't result in a single point of
failure/cascade failure.*

## Sections
* [Pre-requisites](#pre-requisites)
* [Setting up MongoDb](#i-setting-up-mongodb)
* [Setting up ML classifier](#ii-setting-up-ml-classifier)
    * [Oregon State University access](#oregon-state-university-access---ml-classifier)
    * [Non Oregon State University access](#non-oregon-state-university-access---ml-classifier)
* [Setting up NodeJs application](#iii-setting-up-nodejs-application)
    * [Oregon State University access](#oregon-state-university-access---node-app)
    * [Non Oregon State University access](#non-oregon-state-university-access---node-app)

### Pre-requisites

* Docker - Install the latest stable version of docker from [here](https://docs.docker.com/engine/install/ubuntu/)

### I. Setting up MongoDb

1. Download the mongodb image

```sh
docker pull mongo:6.0
```

2. Run a container using the above image

```sh
docker run -dp 27017:27017 --name mongo --restart always mongo:6.0
```

### II. Setting up ML classifier

### Oregon State University access - ML classifier

Continue with this section if you have an Oregon State University account and have access to this Box [folder](https://oregonstate.box.com/s/9evjdwny12h28lar4cyp8s02zouj195i).
If not, jump ahead to the [next](#non-oregon-state-university-access---ml-classifier) section.

1. Ensure you are on a system with x86 architecture and Linux operating system
2. System has at least 2GB of RAM and 24GB of disk space
3. Download the latest ML classifier (spclassifier) tar archive file from the ML Classifier Box folder over [here](https://oregonstate.box.com/s/9evjdwny12h28lar4cyp8s02zouj195i)
4. Unzip the tar archive
    ```sh
    tar -xzvf <filename>.tar.gz
    ```

5. Build a docker image from the tar archive
   ```sh
   docker load --input <filename>.tar
   ```

6. Confirm whether the image has been created successfully by executing the following command
    ```sh
    docker images
    ```

7. Run a docker container using the newly generated image. The command will launch a new container in detached mode.
    ```sh
    docker run -d --env DB_CONN_STR=DB_HOSTNAME --name spclassifier --restart always <image_name>
    ```
   DB_CONN_STR is the mongodb connection string that needs to be passed as an environment variable to the container.
   Example:

    * Using database server's DNS: `DB_CONN_STR=db.domain.com:{port}`
    * Using database server's public/external IP: `DB_CONN_STR=x.x.x.x:{port}`
    * Testing locally: `DB_CONN_STR=localhost:{port}` or `DB_CONN_STR=127.0.0.1:{port}`

8. Inspect the container logs and verify if the pipeline is running without any errors
    ```sh
    docker logs -f --tail 500 spclassifier
    ```

9. Log in to the MongoDb container and verify if records are getting inserted into `recentParkingLots`
   and `parkingLotHistory` collections.

### Non Oregon State University access - ML classifier

1. Ensure that you are on a Linux system with x86 architecture. If you don’t have access to one, follow the below
   instructions.
   Note: These instructions assume that you will be using AWS as the cloud service provider. Skip this step if you are
   using a different provider.
    1. Go to EC2 console in AWS
    2. Create a new instance with the following configuration
        1. Name: MLClassifier
        2. AMI: Ubuntu 22.04
        3. Architecture: 64-bit x86
        4. Type: t2.small
        5. Create a new key pair or select an existing one
        6. In network settings, select the default VPC (Create a new one if you want)
        7. Enable Auto assign public IP
        8. Create a new security group and allow SSH traffic from your IP
        9. In Storage settings, allocate a minimum of 24GiB of gp2 storage
        10. Launch the instance
        11. Connect to the instance through SSH

2. Install docker by following the instructions [here](https://docs.docker.com/engine/install/ubuntu/)
3. Clone the SmartPark-ML-Classifier repository from [here](https://github.com/subramanya1702/SmartPark-ML-Classifier)
   and navigate to `SmartPark-ML-Classifier/smart_park` folder.
4. Download the pytorch file: X-512.pt from [here](https://oregonstate.box.com/s/zhurkyxoxghmfp77fsjgp33rflc37jaq)
5. Now that everything is set up, we can go ahead and build a docker image
    ```sh
    sudo docker build -t spclassifier .
    ```

6. Copy the image to wherever necessary/convenient.
7. Run a docker container using the newly copied image. The command will launch a new container in detached mode.
    ```sh
    sudo docker run -d --env DB_CONN_STR=DB_HOSTNAME --name spclassifier --restart always spclassifier
    ```
   DB_CONN_STR is the mongodb connection string that needs to be passed as an environment variable to the container.
   Example:

    * Using database server's DNS: `DB_CONN_STR=db.domain.com:{port}`
    * Using database server's public/external IP: `DB_CONN_STR=x.x.x.x:{port}`
    * Testing locally: `DB_CONN_STR=localhost:{port}` or `DB_CONN_STR=127.0.0.1:{port}`

8. Log in to the MongoDb container and verify if records are getting inserted into `recentParkingLots`
   and `parkingLotHistory` collections.
9. Don't forget to deallocate any resources that were provisioned on AWS.

### III. Setting up NodeJs Application

### Oregon State University access - Node App

Continue with this section if you have an Oregon State University account and have access to this Box [folder](https://oregonstate.box.com/s/d6s93eufp997fixj04g2kvu7xc5upgy0).
If not, jump ahead to the [next](#non-oregon-state-university-access---node-app) section.

1. Ensure you are on a system with x86 architecture and Linux operating system
2. System has at least 2GB of RAM and 24GB of disk space
3. Download the latest Node App (sprestapi) tar archive file from the Node App Box folder over [here](https://oregonstate.box.com/s/d6s93eufp997fixj04g2kvu7xc5upgy0)
4. Unzip the tar archive
    ```sh
    tar -xzvf <filename>.tar.gz
    ```

5. Build a docker image from the tar archive
   ```sh
   docker load --input <filename>.tar
   ```

6. Confirm whether the image has been created successfully by executing the following command
    ```sh
    docker images
    ```

7. Run a docker container using the newly generated image. The command will launch a new container in detached mode.
    ```sh
    docker run -dp {port}:{port} --env DB_CONN_STR={MONGO_CONNECTION_STRING} --env SERVER_HOSTNAME={NODE_JS_SERVER_HOSTNAME} --name sprestapi --restart always sprestapi 
    ```

DB_CONN_STR is the mongodb connection string that needs to be passed as an environment variable to the container.

Example:

* Using database server's DNS: `DB_CONN_STR=db.domain.com:{port}`
* Using database server's public/external IP: `DB_CONN_STR=x.x.x.x:{port}`
* Testing locally: `DB_CONN_STR=localhost:{port}` or `DB_CONN_STR=127.0.0.1:{port}`

SERVER_HOSTNAME is an optional environment variable that has to be passed if the application is being run in prod mode.
If the application is running in dev mode (running locally), it can be skipped.

Example:

* Using node js server's DNS: `SERVER_HOSTNAME=njs.domain.com`
* Using node js server's public/external IP `SERVER_HOSTNAME=x.x.x.x`

8. Inspect the container logs and verify if the application is running without any errors
    ```sh
    docker logs -f --tail 500 sprestapi
    ```

9. Go to `https://some.domain/parking_lots` or `https://PUBLIC_IP:8080/parking_lots` and verify if you are getting the
   proper response.

### Non Oregon State University access - Node App

1. Ensure that you are on a Linux system with x86 architecture. If you don’t have access to one, follow the below
   instructions.
   Note: These instructions assume that you will be using AWS as the cloud service provider. Skip this step if you are
   using a different provider.
    1. Go to EC2 console in AWS
    2. Create a new instance with the following configuration
        1. Name: NodeApp
        2. AMI: Ubuntu 22.04
        3. Architecture: 64-bit x86
        4. Type: t2.small
        5. Create a new key pair or select an existing one
        6. In network settings, select the default VPC (Create a new one if you want)
        7. Enable Auto assign public IP
        8. Create a new security group and allow SSH traffic from your IP
        9. In Storage settings, allocate a minimum of 24GiB of gp2 storage
        10. Launch the instance
        11. Connect to the instance through SSH

2. Install docker by following the instructions [here](https://docs.docker.com/engine/install/ubuntu/)
3. Clone the SmartPark-REST-API repository from [here](https://github.com/subramanya1702/SmartPark-REST-API) and
   navigate to `SmartPark-REST-API` folder.
4. Now that everything is set up, we can go ahead and build a docker image
    ```sh
    sudo docker build -t sprestapi .
    ```

5. Copy the image to wherever necessary/convenient.
6. Run a docker container using the newly generated image. The command will launch a new container in detached mode.
    ```sh
    docker run -dp {port}:{port} --env DB_CONN_STR={MONGO_CONNECTION_STRING} --env SERVER_HOSTNAME={NODE_JS_SERVER_HOSTNAME} --name sprestapi --restart always sprestapi 
    ```

DB_CONN_STR is the mongodb connection string that needs to be passed as an environment variable to the container.

Example:

* Using database server's DNS: `DB_CONN_STR=db.domain.com:{port}`
* Using database server's public/external IP: `DB_CONN_STR=x.x.x.x:{port}`
* Testing locally: `DB_CONN_STR=localhost:{port}` or `DB_CONN_STR=127.0.0.1:{port}`

SERVER_HOSTNAME is an optional environment variable that has to be passed if the application is being run in prod mode.
If the application is running in dev mode (running locally), it can be skipped.

Example:

* Using node js server's DNS: `SERVER_HOSTNAME=njs.domain.com`
* Using node js server's public/external IP `SERVER_HOSTNAME=x.x.x.x`

7. Inspect the container logs and verify if the application is running without any errors
    ```sh
    docker logs -f --tail 500 sprestapi
    ```

8. Go to `https://some.domain/parking_lots` or `https://PUBLIC_IP:8080/parking_lots` and verify if you are getting the
   proper response.
