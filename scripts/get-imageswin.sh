#!/bin/bash
curl \
https://raw.githubusercontent.com/yannhowe/docker-compose-gitlab/master/docker-compose.yml \
https://raw.githubusercontent.com/bitnami/bitnami-docker-harbor-portal/master/docker-compose.yml \
https://raw.githubusercontent.com/yannhowe/apt-mirror/master/docker-compose.yml \
https://raw.githubusercontent.com/bitnami/bitnami-docker-minio/master/docker-compose.yml \
| grep image: | awk '{print $2}'  | tr -d "'" | xargs -I {} -- sh -c 'docker pull {} && docker tag {} harbor.dev.gov.sg/library/{} && docker push harbor.dev.gov.sg/library/{} > {}.tar'
