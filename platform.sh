#!/bin/bash

DATE=`date +%Y-%m-%d-%H-%M-%S`

case "$1" in
        start)
            docker-compose -f gitlab/docker-compose.yml up -d
            docker-compose -f harbor/docker-compose.yml up -d
            docker-compose -f minio/docker-compose.yml up -d
            docker-compose -f nginx/docker-compose.yml up -d
            docker-compose ps
            ;;
        stop)
            docker-compose -f gitlab/docker-compose.yml down
            docker-compose -f harbor/docker-compose.yml down
            docker-compose -f minio/docker-compose.yml down
            docker-compose -f nginx/docker-compose.yml down
            docker-compose ps
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
            docker-compose ps
            ;;
        apt-sync)
            docker-compose -f apt-mirror/docker-compose-aptmirror-sync.yml up
            ;;
        clean)
            docker-compose -f gitlab/docker-compose.yml down
            docker-compose -f harbor/docker-compose.yml down
            docker-compose -f minio/docker-compose.yml down
            docker-compose -f nginx/docker-compose.yml down
            docker-compose ps
            docker system prune
            ;;
        nuke)
            docker-compose -f gitlab/docker-compose.yml down -v
            docker-compose -f harbor/docker-compose.yml down -v
            docker-compose -f minio/docker-compose.yml down -v
            docker-compose -f nginx/docker-compose.yml down -v
            docker-compose ps
            docker system prune
            ;;
        *)
            echo $"Usage: $0 {start|stop|restart|apt-sync|clean|nuke}"
            exit 1
date
esac