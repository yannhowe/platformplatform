# Platform Bootstrapper
Download and install ubuntu 18.04 in workstation then run the following

```
# Install k8s
sudo apt -y update && sudo apt -y upgrade
sudo snap install microk8s --classic --channel=1.17/stable
sudo usermod -a -G microk8s $USER
su - $USER
microk8s.status --wait-ready
microk8s.enable dns dashboard ingress storage registry

# Alias microk8s.kubectl to kubectl
alias kubectl='microk8s.kubectl'

# Also add microk8s to local kubeconfig so helm can use the config
microk8s.kubectl config view --raw >> ~/.kube/config

# Configure nameservers
echo "\
      nameservers: \
        addresses: [10.2.32.1, 1.1.1.1, 8.8.8.8] \
" >> /etc/netplan/01-netcfg.yaml
cat /etc/netplan/01-netcfg.yaml
sudo netplan apply

# Install Docker-CE
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh


## Install CLIs - - http://gitlab.dev.gov.sg/platform/platform-docs-for-devs/tree/master/kubernetes

# Install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install kubectl 
wget http://artifactory.dev.gov.sg/artifactory/fileshare-generic-local/kubernetes/kubectl-linux-amd64-1.15.5
chmod +x kubectl-linux-amd64-1.15.5
sudo mv kubectl-linux-amd64-1.15.5 /usr/local/bin/kubectl
# shell completion
source <(kubectl completion bash)

# Install pks CLI 
wget http://artifactory.dev.gov.sg/artifactory/fileshare-generic-local/kubernetes/pks-linux-amd64-1.6.1-build.20
chmod +x pks-linux-amd64-1.6.1-build.20
sudo mv pks-linux-amd64-1.6.1-build.20 /usr/local/bin/pks

# Install helm CLI
wget 'http://artifactory.dev.gov.sg/artifactory/fileshare-generic-local/kubernetes/helm-v3.1.1-linux-amd64.tar.gz!/linux-amd64/helm'
chmod +x helm
sudo mv helm /usr/local/bin/helm
# shell completion
source <(helm completion bash)

# Everything working?
docker-compose
kubectl version
pks --version
helm version

# Pull useful images
docker pull yannhowe/docker-pks-cli:release-1.6.1
cat values-microk8s.yaml  | grep repository: | sed 's/^ *repository\: //g'


1. Get the Harbor URL:

  echo "Harbor URL: https://127.0.0.1:8443/"
  kubectl port-forward --namespace default svc/harbor 8443:443

2. Login with the following credentials to see your Harbor application

  echo Username: "admin"
  echo Password: $(kubectl get secret --namespace default harbor-microk8s-core-envvars -o jsonpath="{.data


# make apt-mirror
sudo apt install -y -qq git
git clone https://github.com/yannhowe/apt-mirror.git

# Download all the things in apt
cd apt-mirror
docker-compose up -d
# wait for 160GB+ to come down
```

update sources.list
```
deb [trusted=yes] http://127.0.0.1:8088/ bionic main restricted

deb [trusted=yes] http://127.0.0.1:8088/us.archive.ubuntu.com/ubuntu/ bionic main restricted
deb [trusted=yes] http://127.0.0.1:8088/us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted

deb [trusted=yes] http://127.0.0.1:8088/us.archive.ubuntu.com/ubuntu/ bionic universe
deb [trusted=yes] http://127.0.0.1:8088/us.archive.ubuntu.com/ubuntu/ bionic-updates universe

deb [trusted=yes] http://127.0.0.1:8088/us.archive.ubuntu.com/ubuntu/ bionic multiverse
deb [trusted=yes] http://127.0.0.1:8088/us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse

deb [trusted=yes] http://127.0.0.1:8088/us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse

deb [trusted=yes] http://127.0.0.1:8088/security.ubuntu.com/ubuntu/ bionic-security main restricted
deb [trusted=yes] http://127.0.0.1:8088/security.ubuntu.com/ubuntu/ bionic-security universe
deb [trusted=yes] http://127.0.0.1:8088/security.ubuntu.com/ubuntu/ bionic-security multiverse

deb [arch=amd64, trusted=yes] http://127.0.0.1:8088/download.docker.com/linux/ubuntu bionic stable 
```

Install Gitlab
```
git clone https://github.com/yannhowe/docker-compose-gitlab.git
cd docker-compose-gitlab
docker-compose up -d
```
