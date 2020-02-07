# The Platform platform

## Quickstart
```
# Sync apt-mirror when internet connected, takes a day or so
docker-compose -f ./apps/docker-compose-aptmirror-sync.yml up

# Start the Platform platform
#App(Gitlab & Nginx)
docker-compose -f apps/docker-compose.yml up -d && docker-compose -f apps/docker-compose.yml logs
#Minio
docker-compose -f minio/docker-compose.yml up -d && docker-compose -f minio/docker-compose.yml logs
#Harbor
docker-compose -f harbor/docker-compose.yml up -d && docker-compose -f harbor/docker-compose.yml logs
```

Add the following host file entries or dns entries
```
127.0.0.1      minio.local.org
127.0.0.1      gitlab.local.org
127.0.0.1      harbor.local.org 
127.0.0.1      apt-mirror.local.org
```

Access the services
- [Gitlab](http://gitlab.local.org)
- [MinIO](http://minio.local.org)
- [Harbor](http://harbor.local.org)
- [Apt-Mirror](http://apt-mirror.local.org)

