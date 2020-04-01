#!/bin/bash

DATE=`date +%Y-%m-%d-%H-%M-%S`

case "$1" in
        start)
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose-prod.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml up -d
            ;;
        stop)
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose-prod.yml down
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml down
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml down
            ;;
        restart)
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose-prod.yml down
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml down
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml down
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose-prod.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml up -d
            ;;
        status)
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose-prod.yml ps
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml ps
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml ps
            ;;
        clean)
            docker system prune -a
            ;;
        nuke)
            docker stop $(docker ps -a -q)
            docker rm $(docker ps -a -q)
            docker rmi $(docker images -a)
            docker volume rm $(docker volume ls |awk '{print $2}')
            ;;
        *)
            echo $"Usage: $0 {start|stop|restart|status|clean|nuke}"
            exit 1
date
esac
