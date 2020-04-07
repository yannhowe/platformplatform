#!/bin/bash

case "$1" in
        init)
            if [ -f ./gitlab/.env ]
            then
                export $(cat ./gitlab/.env | xargs)
            fi
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml exec gitlab-runner-1 \
                gitlab-runner register \
                    --non-interactive \
                    --registration-token $REGISTRATION_TOKEN \
                    --locked=false \
                    --description gitlab-runner-1 \
                    --url http://gitlab.platform.net:8088 \
                    --executor docker \
                    --docker-image docker:stable
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml exec gitlab-runner-2 \
                gitlab-runner register \
                    --non-interactive \
                    --registration-token $REGISTRATION_TOKEN \
                    --locked=false \
                    --description gitlab-runner-2 \
                    --url http://gitlab.platform.net:8088 \
                    --executor docker \
                    --docker-image docker:stable
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml exec gitlab-runner-3 \
                gitlab-runner register \
                    --non-interactive \
                    --registration-token $REGISTRATION_TOKEN \
                    --locked=false \
                    --description gitlab-runner-3 \
                    --url http://gitlab.platform.net:8088 \
                    --executor docker \
                    --docker-image docker:stable
            ;;
        start)
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml up -d
            ;;
        stop)
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml down
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml down
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml down
            ;;
        restart)
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml down
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml down
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml down
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml up -d
            ;;
        status)
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml ps
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