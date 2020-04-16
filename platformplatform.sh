#!/bin/bash

services=( nginx minio gitlab airflow apt-mirror chopchop harbor landing-site)

wait_for_container_state () {
    until [ `docker ps --filter "name=$1" --filter "health=$2" --format "{{.Names}}"` ]
    do
        docker ps --filter "name=$1" --format "{{.Names}} {{.Status}}"
        sleep 5
    done
    docker ps --filter "name=$1" --format "{{.Names}} {{.Status}}"
}

register_gitlab_runners () {
    echo "Registering Runners with Gitlab"
    REGISTRATION_TOKEN=`docker exec -it gitlab_gitlab_1 gitlab-rails runner "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"`
    echo "Registration Token: $REGISTRATION_TOKEN"
    docker-compose -f ${PWD}/gitlab/docker-compose.yml exec gitlab-runner-1 \
        gitlab-runner register \
            --non-interactive \
            --registration-token=$REGISTRATION_TOKEN \
            --locked=false \
            --description=gitlab-runner-1 \
            --url=http://gitlab_gitlab_1 \
            --executor docker \
            --docker-image=docker:stable
    docker-compose -f ${PWD}/gitlab/docker-compose.yml exec gitlab-runner-2 \
        gitlab-runner register \
            --non-interactive \
            --registration-token=$REGISTRATION_TOKEN \
            --locked=false \
            --description=gitlab-runner-1 \
            --url=http://gitlab_gitlab_1 \
            --executor docker \
            --docker-image=docker:stable
    docker-compose -f ${PWD}/gitlab/docker-compose.yml exec gitlab-runner-3 \
        gitlab-runner register \
            --non-interactive \
            --registration-token=$REGISTRATION_TOKEN \
            --locked=false \
            --description=gitlab-runner-1 \
            --url=http://gitlab_gitlab_1 \
            --executor docker \
            --docker-image=docker:stable
}

case "$1" in
        init)
            if [ -f ${PWD}/gitlab/.env ]
            then
                export $(cat ${PWD}/gitlab/.env | xargs)
            fi
            if [ -f ${PWD}/.env ]
            then
                export $(cat ${PWD}/.env | xargs)
            fi
            # Enable incremental logs for object storage https://docs.gitlab.com/ee/administration/job_logs.html#enabling-incremental-logging
            echo -n "Setting Feature.enable('ci_enable_live_trace') to "
            docker exec -it gitlab_gitlab_1 gitlab-rails runner "puts Feature.enable('ci_enable_live_trace')"
            register_gitlab_runners
            mc config host add minio_host http://minio.platform.net $MINIO_ACCESS_KEY $MINIO_SECRET_KEY --api S3v4
            ;;
            # https://docs.gitlab.com/ee/administration/troubleshooting/gitlab_rails_cheat_sheet.html
        backup)
            # GitLab
            dt=$(date +'%s_%Y_%m_%d');
            mkdir ${PWD}/gitlab/backup/secrets/$dt
            docker cp gitlab_gitlab_1:/etc/gitlab/ ${PWD}/gitlab/backup/secrets/$dt
            docker exec -t gitlab_gitlab_1 gitlab-backup create
            ;;
        backup_ls)
            docker exec -it gitlab_gitlab_1 ls /var/opt/gitlab/backups/
            ;;
        restore)
            echo "Copying last 7 days backups from object store..."
            mc config host add minio_host http://minio.platform.net testingtesting123 testingtesting123 --api S3v4
            mc mirror --newer-than 7d minio_host/gitlab-backups/ ${PWD}/tmp/backups/
            docker cp  ${PWD}/tmp/backups/ gitlab_gitlab_1:/var/opt/gitlab/
            rm -f ${PWD}/tmp/backups/*
            
            echo "Listing available backups:"
            echo "=========================="
            docker exec -it gitlab_gitlab_1 ls /var/opt/gitlab/backups | grep _gitlab_backup.tar | sed s/_gitlab_backup.tar//g
            echo "=========================="
            echo ""
            read -p 'Backup to restore: ' backup_to_restore
            docker exec -it gitlab_gitlab_1 gitlab-backup restore BACKUP=$backup_to_restore
            
            echo "Listing available secrets:"
            echo "=========================="
            ls -1 ${PWD}/gitlab/backup/secrets
            echo "=========================="
            echo ""
            read -p 'gitlab-secrets.json to restore: ' secret_to_restore
            docker exec -it gitlab_gitlab_1 rm -f /etc/gitlab/gitlab-secrets.json
            docker cp ${PWD}/gitlab/backup/secrets/$secret_to_restore/gitlab/gitlab-secrets.json gitlab_gitlab_1:/etc/gitlab/gitlab-secrets.json
            docker exec -it gitlab_gitlab_1 ls -lRa /etc/gitlab/
            docker exec -it gitlab_gitlab_1 cat /etc/gitlab/gitlab-secrets.json | grep secret_token
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml restart
            ;;
        up)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml up -d
                done
            wait_for_container_state gitlab_gitlab_1 healthy
            register_gitlab_runners
            ;;
        up-ext)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml up -d
                done
	            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose-sync.yml up -d
            wait_for_container_state gitlab_gitlab_1 healthy
            register_gitlab_runners
            ;;
        logs)
            docker-compose -f /home/platypus/Code/platformplatform/$2/docker-compose.yml logs -f
            ;;
        down)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml down --remove-orphans
                done
	            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose-sync.yml down --remove-orphans
            ;;
        down-ext)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml down --remove-orphans
                done
            ;;
        restart)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml down --remove-orphans
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml up -d
                done
            wait_for_container_state gitlab_gitlab_1 healthy
            register_gitlab_runners
            ;;
        ps)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml ps
                done
            ;;
        clean)
            docker system prune -a
            ;;
        redeploy)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml down -v --remove-orphans
                done
            docker volume rm gitlab_gitlab-config gitlab_gitlab-data gitlab_gitlab-logs
            docker system prune -f
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml up -d
                done
            wait_for_container_state gitlab_gitlab_1 healthy
            register_gitlab_runners
            ;;        
        nuke)
            docker stop $(docker ps -a -q)
            docker rm $(docker ps -a -q)
            docker rmi $(docker images -a)
            docker volume rm $(docker volume ls |awk '{print $2}')
            docker system prune -f
            ;;
        *)
            echo $"Usage: $0 {up|down|restart|ps|clean|nuke}"
            exit 1
date
esac
