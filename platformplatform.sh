#!/bin/bash

services=( nginx gitlab airflow harbor minio apt-mirror pypi-mirror chopchop landing-site )

test_curl () {
    echo "HTTP Status Codes:"
    curl -sL -o /dev/null -w "landing - %{http_code}\n" http://platform.net/
    curl -sL -o /dev/null -w "apt-mirror - %{http_code}\n" http://apt-mirror.platform.net/
    curl -sL -o /dev/null -w "pypi-mirror - %{http_code}\n" http://pypi-mirror.platform.net/
    curl -sL -o /dev/null -w "minio - %{http_code}\n" http://minio.platform.net/
    curl -sL -o /dev/null -w "airflow - %{http_code}\n" http://airflow.platform.net/
    curl -sL -o /dev/null -w "gitlab - %{http_code}\n" http://gitlab.platform.net/
    curl -sL -o /dev/null -w "harbor - %{http_code}\n" http://harbor.platform.net/
}

wait_for_container_state () {
    until [ `docker ps --filter "name=$1" --filter "health=$2" --format "{{.Names}}"` ]
    do
        docker ps --filter "name=$1" --format "{{.Names}} {{.Status}}"
        sleep 5
    done
    docker ps --filter "name=$1" --format "{{.Names}} {{.Status}}"
}

register_gitlab_runners () {
    wait_for_container_state gitlab_gitlab_1 healthy
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
            # Enable incremental logs for object storage https://docs.gitlab.com/ee/administration/job_logs.html#enabling-incremental-logging
#            echo -n "Setting Feature.enable('ci_enable_live_trace') to "
#            docker exec -it gitlab_gitlab_1 gitlab-rails runner "puts Feature.enable('ci_enable_live_trace')"
#            register_gitlab_runners
            mc config host add minio_host http://minio.platform.net ${MINIO_PASSWORD_1} ${MINIO_PASSWORD_2} --api S3v4
            ;;
            # https://docs.gitlab.com/ee/administration/troubleshooting/gitlab_rails_cheat_sheet.html
        backup)
            # GitLab
            dt=$(date +'%s_%Y_%m_%d');
            mkdir -p ${PWD}/gitlab/backup/secrets/$dt
            echo "copying gitlab secrets, config is in .env"
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
            register_gitlab_runners
            test_curl
            ;;
        up-ext)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml up -d
                done
	            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose-sync.yml up -d
	            docker-compose -f /home/platypus/Code/platformplatform/pypi-mirror/docker-compose-sync.yml up -d
            wait_for_container_state gitlab_gitlab_1 healthy
            register_gitlab_runners
            test_curl
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
            ;;
        down-ext)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml down --remove-orphans
                done
	            docker-compose -f /home/platypus/Code/platformplatform/apt-mirror/docker-compose-sync.yml down --remove-orphans
	            docker-compose -f /home/platypus/Code/platformplatform/pypi-mirror/docker-compose-sync.yml down --remove-orphans
            ;;
        restart)
            echo "Stopping Services"
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml down --remove-orphans
                done
            echo "Starting Services"
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml up -d
                done
            register_gitlab_runners
            test_curl
            ;;
        redeploy)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml down -v --remove-orphans
                done
            docker volume rm gitlab_gitlab-config gitlab_gitlab-data gitlab_gitlab-logs
            docker system prune -f
            rm -rf ./minio/data/.minio.sys
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml up -d
                done
            register_gitlab_runners
            test_curl
            ;;        
        ps)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml ps
                done
            test_curl
            ;;
        pull)
            for i in "${services[@]}"
                do
                    :
                    docker-compose -f /home/platypus/Code/platformplatform/$i/docker-compose.yml pull
                done
            ;;
        clean)
            docker system prune -a
            ;;
        nuke)
            docker stop $(docker ps -a -q)
            docker rm $(docker ps -a -q)
            docker rmi $(docker images -a)
            docker volume rm $(docker volume ls |awk '{print $2}')
            docker system prune -f
            ;;
        test)
            test_curl
            ;;
        pwgen) # Generate a password file
            FILE=./.pwgen
            if test -f "$FILE"; then
                echo "$FILE exists"
                echo "Run '. ./platformplatform.sh pwgen' to export to env, delete $FILE to regenerate"
                source .pwgen
                return
            fi
            echo "Generating new credentials"
            echo -n "" > .pwgen
            for service in "${services[@]}"
                do
                    :
                    count=1
                    for i in {1..5}
                        do
                            :
                            echo "export "`echo ${service^^} | sed s/\-/\_/g`"_USER_"$count=${service^^}"_USER_"$count >> .pwgen
                            echo "export "`echo ${service^^} | sed s/\-/\_/g`"_PASSWORD_"$count=`pwgen -Bs1 20` >> .pwgen
                            (( count++ ))
                        done
                done
            # parse gitlab config in ./gitlab/docker-compose.yml comments into one liner and stuff in to env variable
            echo -n "`cat gitlab/docker-compose.yml | grep '##' | sed 's/##\ \ \ \ //g' | grep -v '#' | sed "s/minio_aws_access_key_id/${MINIO_PASSWORD_1}/g" | sed "s/minio_aws_secret_access_key/${MINIO_PASSWORD_2}/g" |  sed ':a;N;$!ba;s/\n/\\n/g'`" > gitlab.config
            echo -n "export GITLAB_OMNIBUS_CONFIG_PWGEN=\"" >> .pwgen
            cat gitlab.config | grep -v export |  sed ':a;N;$!ba;s/\n/\\n/g' | tr -d '\n' >>  .pwgen
            echo -n "\"" >> .pwgen
            source .pwgen
            echo "Run this command: '. ./platformplatform.sh pwgen' to have the env variables exported"
            echo "please restart the platformplatform"
            ;;
        *)
            echo $"Usage: $0 {init|backup|backup_ls|restore|up|up-ext|logs|down|down-ext|restart|ps|clean|redeploy|nuke|test|pwgen}"
            exit 1
date
esac