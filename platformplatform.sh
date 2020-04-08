#!/bin/bash

wait_for_container_state () {
    until [ `docker ps --filter "name=$1" --filter "health=$2" --format "{{.Names}}"` ]
    do
        docker ps --filter "name=$1" --format "{{.Names}} {{.Status}}"
        sleep 5
    done
    docker ps --filter "name=$1" --format "{{.Names}} {{.Status}}"
}

case "$1" in
        init)
            if [ -f ./gitlab/.env ]
            then
                export $(cat ./gitlab/.env | xargs)
            fi
            docker-compose -f ${PWD}/gitlab/docker-compose.yml exec gitlab-runner-1 \
                gitlab-runner register \
                    --non-interactive \
                    --registration-token $REGISTRATION_TOKEN \
                    --locked=false \
                    --description gitlab-runner-1 \
                    --url http://platformplatform_gitlab_1 \
                    --executor docker \
                    --docker-image docker:stable
            docker-compose -f ${PWD}/gitlab/docker-compose.yml exec gitlab-runner-2 \
                gitlab-runner register \
                    --non-interactive \
                    --registration-token $REGISTRATION_TOKEN \
                    --locked=false \
                    --description gitlab-runner-2 \
                    --url http://platformplatform_gitlab_1 \
                    --executor docker \
                    --docker-image docker:stable
            docker-compose -f ${PWD}/gitlab/docker-compose.yml exec gitlab-runner-3 \
                gitlab-runner register \
                    --non-interactive \
                    --registration-token $REGISTRATION_TOKEN \
                    --locked=false \
                    --description gitlab-runner-3 \
                    --url http://platformplatform_gitlab_1 \
                    --executor docker \
                    --docker-image docker:stable
            ;;
        backup)
            # GitLab
            dt=$(date +'%s_%Y_%m_%d');
            mkdir ${PWD}/gitlab/backup/secrets/$dt
            docker cp platformplatform_gitlab_1:/etc/gitlab/ ${PWD}/gitlab/backup/secrets/$dt
            docker exec -t platformplatform_gitlab_1 gitlab-backup create
            ;;
        backup_ls)
            docker exec -it platformplatform_gitlab_1 ls /var/opt/gitlab/backups/
            ;;
        restore)
            echo "Listing available backups:"
            echo "=========================="
            docker exec -it platformplatform_gitlab_1 ls /var/opt/gitlab/backups
            echo "=========================="
            echo ""
            read -p 'Backup to restore: ' backup_to_restore
            docker exec -it platformplatform_gitlab_1 gitlab-backup restore BACKUP=$backup_to_restore
            
            ;;
        up)
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml up  -d
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/minio/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/nginx/docker-compose.yml up -d
            wait_for_container_state platformplatform_gitlab_1 healthy
            ;;
        down)
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml down --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml down --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/minio/docker-compose.yml down --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml down --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/nginx/docker-compose.yml down --remove-orphans
            ;;
        restart)
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml down --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml down --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/minio/docker-compose.yml down --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml down --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/nginx/docker-compose.yml down --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/minio/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/nginx/docker-compose.yml up -d
            wait_for_container_state platformplatform_gitlab_1 healthy
            ;;
        ps)
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml ps
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml ps
            docker-compose -f /home/platypus/Code/platformplatform/minio/docker-compose.yml ps
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml ps
            docker-compose -f /home/platypus/Code/platformplatform/nginx/docker-compose.yml ps
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
            echo $"Usage: $0 {up|down|restart|ps|clean|nuke}"
            exit 1
date
esac