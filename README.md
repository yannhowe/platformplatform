# The Platform platform

## Quickstart
```
# Sync apt-mirror when internet connected, takes a day or so
docker-compose -f ./apps/docker-compose-aptmirror-sync.yml up

# Start the platformplatform gitlab instance
export DOCKER_HOST=ssh://platypus@192.168.88.1
./platform.sh start
```

Add the Runner registration token found [here](http://gitlab.platform.net:8080/admin/runners) to .env file
```
echo "mytokenmytoken" > .env
```
Configure Runner to run [untagged tasks](https://docs.gitlab.com/ee/ci/runners/#runner-is-allowed-to-run-untagged-jobs)

Add an existing kubernetes cluster to gitlab
```
# Get kube cert to paste in gitlab
kubectl get secret `kubectl get secrets | grep default-token- | awk '{print $1}'` -o jsonpath="{['data']['ca\.crt']}" | base64 --decode
kubectl apply -f ./config/gitlab/gitlab-admin-service-account.yaml
# Get gitlab token to paste in Service Token field
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab-admin | awk '{print $1}') | grep token: |  awk '{print $2}'

```

# Register the platformplatform gitlab runner instance
```
./platform.sh register
```

Add the following host file entries or dns entries
```
127.0.0.1      platform.net
127.0.0.1      registry.platform.net
127.0.0.1      minio.platform.net
127.0.0.1      gitlab.platform.net
127.0.0.1      harbor.platform.net 
127.0.0.1      apt-mirror.platform.net
```

Access the services
- [Gitlab](http://gitlab.platform.net)
- [MinIO](http://minio.platform.net)
- [Harbor](http://harbor.platform.net)
- [Apt-Mirror](http://apt-mirror.platform.net)