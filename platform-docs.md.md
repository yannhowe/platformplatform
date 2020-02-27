# Platform Bootstrapper
Download and install ubuntu 18.04 in workstation then run the following while connected to internet


## Set up local Apt Mirror (Optional for offline use)
```
sudo apt install -y -qq git
git clone https://github.com/yannhowe/platformplatform.git

# Download all the things in apt mirror
docker-compose -f platformplatform/apt-mirror/docker-compose.yml up -d
# wait for 160GB+ to come down
```

## Install microk8s
```
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
```

## Install Docker-CE & CLIs
```
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh

export kubectl_version=1.15.5
export docker_compose_version=1.25.4
export pks_version=1.6.1
export helm_version=3.1.1
export velero_version=1.2.0

echo "Installing 'kubectl' v${kubectl_version}" \
&&   sudo wget -cO /usr/local/bin/kubectl  https://storage.googleapis.com/kubernetes-release/release/v${kubectl_version}/bin/linux/amd64/kubectl \
&&   chmod 0755 /usr/local/bin/kubectl \
&&   kubectl version --client \
&& echo "Installing 'docker-compose' v${docker_compose_version}" \
&&   sudo wget -cO /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-$(uname -s)-$(uname -m) \
&&   sudo chmod 0755 /usr/local/bin/docker-compose \
&&   docker-compose --version \
&& echo "Installing 'helm' v${helm_version}" \
&&   wget -c https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz \
&&   tar -zxvf helm-v${helm_version}-linux-amd64.tar.gz \
&&   chmod 0755 ./linux-amd64/helm \
&&   sudo mv ./linux-amd64/helm /usr/local/bin/helm \
&&   rm -rf helm-v${helm_version}-linux-amd64.tar.gz ./linux-amd64/ \
&&   helm \
&& echo "Installing 'velero' v${velero_version}" \
&&   wget -c https://github.com/vmware-tanzu/velero/releases/download/v${velero_version}/velero-v${velero_version}-linux-amd64.tar.gz \
&&   tar -zxvf velero-v${velero_version}-linux-amd64.tar.gz \
&&   chmod 0755 ./velero-v${velero_version}-linux-amd64/velero \
&&   sudo mv ./velero-v${velero_version}-linux-amd64/velero /usr/local/bin/velero \
&&   rm -rf velero-v${velero_version}-linux-amd64.tar.gz ./velero-v${velero_version}-linux-amd64 \
&&   velero

# Everything working?
docker-compose
kubectl version
pks --version
helm version
velero version
```

## Change to local APT repo
```
sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak.`date +%Y-%m-%dT%H:%M:%S%z`

sudo tee -a /etc/apt/sources.list > /dev/null <<EOT
deb [trusted=yes] http://apt-mirror.platform.net:1080/ bionic main restricted
deb [trusted=yes] http://apt-mirror.platform.net:1080/us.archive.ubuntu.com/ubuntu/ bionic main restricted
deb [trusted=yes] http://apt-mirror.platform.net:1080/us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted
deb [trusted=yes] http://apt-mirror.platform.net:1080/us.archive.ubuntu.com/ubuntu/ bionic universe
deb [trusted=yes] http://apt-mirror.platform.net:1080/us.archive.ubuntu.com/ubuntu/ bionic-updates universe
deb [trusted=yes] http://apt-mirror.platform.net:1080/us.archive.ubuntu.com/ubuntu/ bionic multiverse
deb [trusted=yes] http://apt-mirror.platform.net:1080/us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse
deb [trusted=yes] http://apt-mirror.platform.net:1080/us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse
deb [trusted=yes] http://apt-mirror.platform.net:1080/security.ubuntu.com/ubuntu/ bionic-security main restricted
deb [trusted=yes] http://apt-mirror.platform.net:1080/security.ubuntu.com/ubuntu/ bionic-security universe
deb [trusted=yes] http://apt-mirror.platform.net:1080/security.ubuntu.com/ubuntu/ bionic-security multiverse
deb [arch=amd64, trusted=yes] http://apt-mirror.platform.net:1080/download.docker.com/linux/ubuntu bionic stable
EOT

sudo apt update
```

# Configure nameservers & hostsfile
```
echo "\
      nameservers: \
        addresses: [10.2.32.1, 1.1.1.1, 8.8.8.8] \
" >> /etc/netplan/01-netcfg.yaml
cat /etc/netplan/01-netcfg.yaml
sudo netplan apply

echo "127.0.0.1      platform.net" >> /etc/hosts
echo "127.0.0.1      registry.platform.net" >> /etc/hosts
echo "127.0.0.1      minio.platform.net" >> /etc/hosts
echo "127.0.0.1      gitlab.platform.net" >> /etc/hosts
echo "127.0.0.1      harbor.platform.net" >> /etc/hosts
echo "127.0.0.1      apt-mirror.platform.net" >> /etc/hosts
```

## Run Gitlab
```
docker-compose -f platformplatform/gitlab/docker-compose.yml up -d
```
