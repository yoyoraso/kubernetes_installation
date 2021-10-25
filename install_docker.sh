#!/bin/bash

#Insatll Docker:

sudo yum install -y yum-utils

sudo yum-config-manager \
                --add-repo \
                https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce-18.09.0-3.el7  docker-ce-cli-18.09.0-3.el7  containerd.io-18.09.0-3.el7 

sudo systemctl enable docker

sudo systemctl start docker

#checking docker installation

sudo docker run hello-world

