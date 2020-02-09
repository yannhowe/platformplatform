#!/bin/bash

DATE=`date +%Y-%m-%d-%H-%M-%S`

case "$1" in
        start)
            docker-compose -f gitlab/docker-compose.yml up -d
            docker-compose -f harbor/docker-compose.yml up -d
            docker-compose -f minio/docker-compose.yml up -d
            docker-compose -f nginx/docker-compose.yml up -d
            docker ps
            ;;
        stop)
            docker-compose -f gitlab/docker-compose.yml down
            docker-compose -f harbor/docker-compose.yml down
            docker-compose -f minio/docker-compose.yml down
            docker-compose -f nginx/docker-compose.yml down
            docker ps
            ;;
        restart)
            docker-compose -f gitlab/docker-compose.yml down
            docker-compose -f harbor/docker-compose.yml down
            docker-compose -f minio/docker-compose.yml down
            docker-compose -f nginx/docker-compose.yml down
            docker-compose -f gitlab/docker-compose.yml up -d
            docker-compose -f harbor/docker-compose.yml up -d
            docker-compose -f minio/docker-compose.yml up -d
            docker-compose -f nginx/docker-compose.yml up -d
            docker ps
            ;;
        apt-sync)
            docker-compose -f apt-mirror/docker-compose-aptmirror-sync.yml up
            ;;
        clean)
            docker-compose -f gitlab/docker-compose.yml down
            docker-compose -f harbor/docker-compose.yml down
            docker-compose -f minio/docker-compose.yml down
            docker-compose -f nginx/docker-compose.yml down
            docker ps -a
            docker system prune
            docker ps -a
            ;;
        nuke)
            docker-compose -f gitlab/docker-compose.yml down -v
            docker-compose -f harbor/docker-compose.yml down -v
            docker-compose -f minio/docker-compose.yml down -v
            docker-compose -f nginx/docker-compose.yml down -v
            docker ps -a
            docker system prune
            docker ps -a
            ;;
        *)
            echo $"Usage: $0 {start|stop|restart|apt-sync|clean|nuke}"
            exit 1
date
esac