#!/bin/bash
sudo apt-get update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker
sudo usermod -aG docker ubuntu

docker pull urgentamang/localtomcatimg:79
docker stop tomcatInstanceProd || true
docker rm tomcatInstanceProd || true
docker run -itd --name tomcatInstanceProd -p 8083:8080  urgentamang/localtomcatimg:79