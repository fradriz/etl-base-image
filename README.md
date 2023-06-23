# etl-base-image
Docker image with the base libraries for the ETLs

## DOCKER
Base image is using these packages and versions to run PySpark:
* OpenJDK -> openjdk:8-slim-buster
* Python -> python:3.9.2-slim-buster
* PySpark -> (3.1.2) 3.1.3
* Delta Lake -> 1.0.0

Is possible to change some of these versions. See the [image github repo](https://github.com/ykursadkaya/pyspark-Docker) for more details

### BUILD
```shell
$ sudo docker build -t etl-base-image .
```
OBS: To build it locally copy the `~/.aws/credentials` file to the etl-base-image root folder.

### BUILD WITH DIFFERENT PYTHON VersionF
In case we want to modify the python version
```shell
$ sudo docker build -t etl-base-image --build-arg PYTHON_VERSION=3.7.10 .
```

### RUN
Open a bash shell to test it from the inside
```shell
$ docker run -it --entrypoint /bin/bash etl-base-image
```

# FARGATE
Updating the ecr image
```shell
# after building the image locally run:
AWS_ACCOUNT_ID=1234
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
# then:
docker tag $(sudo docker images | awk '{print $3}' | awk 'NR==2') $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/etl-base-image
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/etl-base-image
```

