#!/bin/bash
curl https://raw.githubusercontent.com/yannhowe/docker-compose-gitlab/master/docker-compose.yml | sed 's/image\: \x27/image\: \x27harbor.local\//g' > docker-compose-gitlab.yml && \
curl https://raw.githubusercontent.com/bitnami/bitnami-docker-harbor-portal/master/docker-compose.yml | sed 's/image\: /image\: harbor.local\//g' > docker-compose-harbor.yml && \
curl https://raw.githubusercontent.com/yannhowe/apt-mirror/master/docker-compose.yml | sed 's/image\: \x27/image\: \x27harbor.local\//g' > docker-compose-apt-mirror.yml && \
curl https://raw.githubusercontent.com/bitnami/bitnami-docker-minio/master/docker-compose.yml | sed 's/image\: /image\: harbor.local\//g' > docker-compose-minio.yml