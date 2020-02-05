# The Platform platform

## Quickstart
```
# Sync apt-mirror when internet connected, takes a day or so
docker-compose -f docker-compose-aptmirror-sync.yml up

# Start the Platform platform
docker-compose up -d && docker-compose logs -f
```

Access the services
- [Gitlab](http://gitlab.local.org)
- [MinIO](http://minio.local.org)
- [Harbor](http://harbor.local.org)
- [Apt-Mirror](http://apt-mirror.local.org)