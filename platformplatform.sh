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
            if [ -f ${PWD}/gitlab/.env ]
            then
                export $(cat ${PWD}/gitlab/.env | xargs)
            fi
            # Enable incremental logs for object storage https://docs.gitlab.com/ee/administration/job_logs.html#enabling-incremental-logging
            docker exec -it platformplatform_gitlab_1 gitlab-rails runner "puts Feature.enable('ci_enable_live_trace')"
            REGISTRATION_TOKEN=`docker exec -it platformplatform_gitlab_1 gitlab-rails runner "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"`
            echo "Registration Token: $REGISTRATION_TOKEN"
            docker-compose -f ${PWD}/gitlab/docker-compose.yml exec gitlab-runner-1 \
                gitlab-runner register \
                    --non-interactive \
                    --registration-token=$REGISTRATION_TOKEN \
                    --locked=false \
                    --description=gitlab-runner-1 \
                    --url=http://platformplatform_gitlab_1 \
                    --executor docker \
                    --docker-image=docker:stable
            docker-compose -f ${PWD}/gitlab/docker-compose.yml exec gitlab-runner-2 \
                gitlab-runner register \
                    --non-interactive \
                    --registration-token=$REGISTRATION_TOKEN \
                    --locked=false \
                    --description=gitlab-runner-1 \
                    --url=http://platformplatform_gitlab_1 \
                    --executor docker \
                    --docker-image=docker:stable
            docker-compose -f ${PWD}/gitlab/docker-compose.yml exec gitlab-runner-3 \
                gitlab-runner register \
                    --non-interactive \
                    --registration-token=$REGISTRATION_TOKEN \
                    --locked=false \
                    --description=gitlab-runner-1 \
                    --url=http://platformplatform_gitlab_1 \
                    --executor docker \
                    --docker-image=docker:stable
            mc config host add minio_host http://minio.platform.net testingtesting123 testingtesting123 --api S3v4
            ;;
            # https://docs.gitlab.com/ee/administration/troubleshooting/gitlab_rails_cheat_sheet.html
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
            echo "Copying last 7 days backups from object store..."
            mc config host add minio_host http://minio.platform.net testingtesting123 testingtesting123 --api S3v4
            mc mirror --newer-than 7d minio_host/gitlab-backups/ ${PWD}/tmp/backups/
            docker cp  ${PWD}/tmp/backups/ platformplatform_gitlab_1:/var/opt/gitlab/
            rm -f ${PWD}/tmp/backups/*
            
            echo "Listing available backups:"
            echo "=========================="
            docker exec -it platformplatform_gitlab_1 ls /var/opt/gitlab/backups | grep _gitlab_backup.tar | sed s/_gitlab_backup.tar//g
            echo "=========================="
            echo ""
            read -p 'Backup to restore: ' backup_to_restore
            docker exec -it platformplatform_gitlab_1 gitlab-backup restore BACKUP=$backup_to_restore
            
            echo "Listing available secrets:"
            echo "=========================="
            ls -1 ${PWD}/gitlab/backup/secrets
            echo "=========================="
            echo ""
            read -p 'gitlab-secrets.json to restore: ' secret_to_restore
            docker exec -it platformplatform_gitlab_1 rm -f /etc/gitlab/gitlab-secrets.json
            docker cp ${PWD}/gitlab/backup/secrets/$secret_to_restore/gitlab/gitlab-secrets.json platformplatform_gitlab_1:/etc/gitlab/gitlab-secrets.json
            docker exec -it platformplatform_gitlab_1 ls -lRa /etc/gitlab/
            docker exec -it platformplatform_gitlab_1 cat /etc/gitlab/gitlab-secrets.json | grep secret_token
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml restart
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
        redeploy)
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml down -v --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml down -v --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/minio/docker-compose.yml down -v --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml down -v --remove-orphans
            docker-compose -f /home/platypus/Code/platformplatform/nginx/docker-compose.yml down -v --remove-orphans
            docker volume rm platformplatform_gitlab-config platformplatform_gitlab-data platformplatform_gitlab-logs
            docker system prune -f
            docker-compose -f /home/platypus/Code/platformplatform/gitlab/docker-compose.yml up  -d
            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/minio/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/chopchop/docker-compose.yml up -d
            docker-compose -f /home/platypus/Code/platformplatform/nginx/docker-compose.yml up -d
            wait_for_container_state platformplatform_gitlab_1 healthy
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