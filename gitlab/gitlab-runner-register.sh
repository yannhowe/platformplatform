#!/bin/sh
# Get the registration token from:
# http://localhost:8080/root/${project}/settings/ci_cd

registration_token=bVnpuA9Sri8LoC62RJrv
  
docker exec -it gitlab-runner-1 \
  gitlab-runner register \
    --non-interactive \
    --registration-token ${registration_token} \
    --locked=false \
    --description gitlab-runner-1 \
    --url http://gitlab.platform.net:8080 \
    --executor docker \
    --docker-image docker:stable
