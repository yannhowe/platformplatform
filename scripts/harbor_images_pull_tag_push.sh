#!/bin/bash

# Dabao Harbor Helm Chart Images
docker pull bitnami/harbor-core:1.10.1-debian-10-r6
docker pull bitnami/harbor-portal:1.10.1-debian-10-r7
docker pull bitnami/harbor-jobservice:1.10.1-debian-10-r6
docker pull bitnami/chartmuseum:0.11.0-debian-10-r23
docker pull bitnami/harbor-registry:1.10.1-debian-10-r6
docker pull bitnami/harbor-registryctl:1.10.1-debian-10-r6
docker pull bitnami/harbor-clair:1.10.1-debian-10-r6
docker pull bitnami/harbor-adapter-clair:1.0.1-debian-10-r23
docker pull bitnami/harbor-notary-server:1.10.1-debian-10-r6
docker pull bitnami/harbor-notary-signer:1.10.1-debian-10-r6
docker pull bitnami/nginx:1.16.1-debian-10-r24
docker pull bitnami/minideb:buster

docker tag bitnami/harbor-core:1.10.1-debian-10-r6 127.0.0.1:32000/bitnami/harbor-core:1.10.1-debian-10-r6
docker tag bitnami/harbor-portal:1.10.1-debian-10-r7 127.0.0.1:32000/bitnami/harbor-portal:1.10.1-debian-10-r7
docker tag bitnami/harbor-jobservice:1.10.1-debian-10-r6 127.0.0.1:32000/bitnami/harbor-jobservice:1.10.1-debian-10-r6
docker tag bitnami/chartmuseum:0.11.0-debian-10-r23 127.0.0.1:32000/bitnami/chartmuseum:0.11.0-debian-10-r23
docker tag bitnami/harbor-registry:1.10.1-debian-10-r6 127.0.0.1:32000/bitnami/harbor-registry:1.10.1-debian-10-r6
docker tag bitnami/harbor-registryctl:1.10.1-debian-10-r6 127.0.0.1:32000/bitnami/harbor-registryctl:1.10.1-debian-10-r6
docker tag bitnami/harbor-clair:1.10.1-debian-10-r6 127.0.0.1:32000/bitnami/harbor-clair:1.10.1-debian-10-r6
docker tag bitnami/harbor-adapter-clair:1.0.1-debian-10-r23 127.0.0.1:32000/bitnami/harbor-adapter-clair:1.0.1-debian-10-r23
docker tag bitnami/harbor-notary-server:1.10.1-debian-10-r6 127.0.0.1:32000/bitnami/harbor-notary-server:1.10.1-debian-10-r6
docker tag bitnami/harbor-notary-signer:1.10.1-debian-10-r6 127.0.0.1:32000/bitnami/harbor-notary-signer:1.10.1-debian-10-r6
docker tag bitnami/nginx:1.16.1-debian-10-r24 127.0.0.1:32000/bitnami/nginx:1.16.1-debian-10-r24
docker tag bitnami/minideb:buster 127.0.0.1:32000/bitnami/minideb:buster

docker push 127.0.0.1:32000/bitnami/harbor-core:1.10.1-debian-10-r6
docker push 127.0.0.1:32000/bitnami/harbor-portal:1.10.1-debian-10-r7
docker push 127.0.0.1:32000/bitnami/harbor-jobservice:1.10.1-debian-10-r6
docker push 127.0.0.1:32000/bitnami/chartmuseum:0.11.0-debian-10-r23
docker push 127.0.0.1:32000/bitnami/harbor-registry:1.10.1-debian-10-r6
docker push 127.0.0.1:32000/bitnami/harbor-registryctl:1.10.1-debian-10-r6
docker push 127.0.0.1:32000/bitnami/harbor-clair:1.10.1-debian-10-r6
docker push 127.0.0.1:32000/bitnami/harbor-adapter-clair:1.0.1-debian-10-r23
docker push 127.0.0.1:32000/bitnami/harbor-notary-server:1.10.1-debian-10-r6
docker push 127.0.0.1:32000/bitnami/harbor-notary-signer:1.10.1-debian-10-r6
docker push 127.0.0.1:32000/bitnami/nginx:1.16.1-debian-10-r24
docker push 127.0.0.1:32000/bitnami/minideb:buster

# Dabao Harbor Helm Sub-Chart Images
docker pull bitnami/postgresql:11.7.0-debian-10-r0
docker pull bitnami/redis:5.0.7-debian-10-r0

docker tag bitnami/postgresql:11.7.0-debian-10-r0 127.0.0.1:32000/bitnami/postgresql:11.7.0-debian-10-r0
docker tag bitnami/redis:5.0.7-debian-10-r0 127.0.0.1:32000/bitnami/redis:5.0.7-debian-10-r0

docker push  127.0.0.1:32000/bitnami/postgresql:11.7.0-debian-10-r0
docker push  127.0.0.1:32000/bitnami/redis:5.0.7-debian-10-r0

# Dabao Contour Stuff
docker pull projectcontour/contour:v1.2.0
docker pull docker.io/envoyproxy/envoy:v1.13.0

docker tag  projectcontour/contour:v1.2.0 127.0.0.1:32000/projectcontour/contour:v1.2.0
docker tag docker.io/envoyproxy/envoy:v1.13.0 127.0.0.1:32000/envoyproxy/envoy:v1.13.0

docker push 127.0.0.1:32000/projectcontour/contour:v1.2.0
docker push 127.0.0.1:32000/envoyproxy/envoy:v1.13.0