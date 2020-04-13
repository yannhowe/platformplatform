# Platform Bootstrapper
Download and install ubuntu 18.04 in workstation then run the following while connected to internet


## Set up local Apt Mirror (Optional for offline use)
```
sudo echo # This prevents sudo from asking you for a password later
sudo apt install -y -qq git
git clone https://github.com/yannhowe/platformplatform.git

# Download all the things in apt mirror
docker-compose -f platformplatform/apt-mirror/docker-compose.yml up -d
# wait for 160GB+ to come down

# Set up automatic updates

sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades > /dev/null <<EOT
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOT

```

## Install microk8s
```
export microk8s_version=1.15/stable

sudo echo # This prevents sudo from asking you for a password later
sudo apt -y update && sudo apt -y upgrade
sudo snap install microk8s --classic --channel=${microk8s_version}
sudo usermod -a -G microk8s $USER
exit # exit shall to let permissions take effect

microk8s.status --wait-ready
microk8s.enable dns dashboard ingress storage registry

# Alias microk8s.kubectl to kubectl
alias kubectl='microk8s.kubectl'

# Also add microk8s to local kubeconfig so helm can use the config
microk8s.kubectl config view --raw >> ~/.kube/config
```

## Install Docker-CE
```
sudo echo # This prevents sudo from asking you for a password later
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group so you don't need to sudo 
sudo usermod -aG docker $USER
# exit shell for changes to take effect
```

## Install CLIs
```
export kubectl_version=1.15.5
export docker_compose_version=1.25.4
export pks_version=1.6.1
export helm_version=3.1.1
export velero_version=1.2.0

echo "Installing 'pks' v${pks_version}" \
&& sudo wget -cO /usr/local/bin/pks https://github.com/yannhowe/docker-pks-cli/raw/master/pks_cli/pks-linux-amd64-1.6.1 \
&& echo "Installing 'kubectl' v${kubectl_version}" \
&&   sudo wget -cO /usr/local/bin/kubectl  https://storage.googleapis.com/kubernetes-release/release/v${kubectl_version}/bin/linux/amd64/kubectl \
&&   sudo chmod 0755 /usr/local/bin/kubectl \
&&   kubectl version --client \
&& echo "Installing 'docker-compose' v${docker_compose_version}" \
&&   sudo wget -cO /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-$(uname -s)-$(uname -m) \
&&   sudo chmod 0755 /usr/local/bin/docker-compose \
&&   docker-compose --version \
&& echo "Installing 'helm' v${helm_version}" \
&&   sudo wget -c https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz \
&&   sudo tar -zxvf helm-v${helm_version}-linux-amd64.tar.gz \
&&   sudo chmod 0755 ./linux-amd64/helm \
&&   sudo mv ./linux-amd64/helm /usr/local/bin/helm \
&&   sudo rm -rf helm-v${helm_version}-linux-amd64.tar.gz ./linux-amd64/ \
&&   helm \
&& echo "Installing 'velero' v${velero_version}" \
&&   sudo wget -c https://github.com/vmware-tanzu/velero/releases/download/v${velero_version}/velero-v${velero_version}-linux-amd64.tar.gz \
&&   sudo tar -zxvf velero-v${velero_version}-linux-amd64.tar.gz \
&&   sudo chmod 0755 ./velero-v${velero_version}-linux-amd64/velero \
&&   sudo mv ./velero-v${velero_version}-linux-amd64/velero /usr/local/bin/velero \
&&   sudo rm -rf velero-v${velero_version}-linux-amd64.tar.gz ./velero-v${velero_version}-linux-amd64 \
&&   velero \
&&   echo "Installing 'mc" \
&&   sudo wget -c https://dl.min.io/client/mc/release/linux-amd64/mc \
&&   sudo chmod +x mc \
&&   sudo mv mc /usr/local/bin/mc \
&&   mc config host add minio_host http://minio.platform.net testingtesting123 testingtesting123 --api S3v4


# Everything working?
docker-compose
kubectl version
pks --version
helm version
velero version
mc 
```

## Change to local APT repo
```
sudo echo # This prevents sudo from asking you for a password later
sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak.`date +%Y-%m-%dT%H:%M:%S%z`

sudo tee -a /etc/apt/sources.list > /dev/null <<EOT
deb [trusted=yes] http://apt-mirror.platform.net/ bionic main restricted
deb [trusted=yes] http://apt-mirror.platform.net/us.archive.ubuntu.com/ubuntu/ bionic main restricted
deb [trusted=yes] http://apt-mirror.platform.net/us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted
deb [trusted=yes] http://apt-mirror.platform.net/us.archive.ubuntu.com/ubuntu/ bionic universe
deb [trusted=yes] http://apt-mirror.platform.net/us.archive.ubuntu.com/ubuntu/ bionic-updates universe
deb [trusted=yes] http://apt-mirror.platform.net/us.archive.ubuntu.com/ubuntu/ bionic multiverse
deb [trusted=yes] http://apt-mirror.platform.net/us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse
deb [trusted=yes] http://apt-mirror.platform.net/us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse
deb [trusted=yes] http://apt-mirror.platform.net/security.ubuntu.com/ubuntu/ bionic-security main restricted
deb [trusted=yes] http://apt-mirror.platform.net/security.ubuntu.com/ubuntu/ bionic-security universe
deb [trusted=yes] http://apt-mirror.platform.net/security.ubuntu.com/ubuntu/ bionic-security multiverse
deb [arch=amd64, trusted=yes] http://apt-mirror.platform.net/download.docker.com/linux/ubuntu bionic stable
EOT

sudo apt update
```

# Configure nameservers & hostsfile
```
sudo echo # This prevents sudo from asking you for a password later
sudo tee -a /etc/netplan/01-netcfg.yaml > /dev/null <<EOT
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: yes
      nameservers:
        addresses: [10.2.32.1, 1.1.1.1, 8.8.8.8]

EOT
sudo netplan apply


sudo tee -a /etc/hosts > /dev/null <<EOT
127.0.0.1      platform.net
127.0.0.1      registry.platform.net
127.0.0.1      minio.platform.net
127.0.0.1      gitlab.platform.net
127.0.0.1      harbor.platform.net
127.0.0.1      apt-mirror.platform.net
EOT
```

## Run Gitlab
```
docker-compose -f platformplatform/gitlab/docker-compose.yml up -d
```

## Install Packer on laptop with workstation for building images
```
export VER="1.5.5"
sudo wget https://releases.hashicorp.com/packer/${VER}/packer_${VER}_linux_amd64.zip
sudo unzip packer_${VER}_linux_amd64.zip
sudo mv packer /usr/local/bin
sudo chmod +x /usr/local/bin/packer
packer
```

## Start platform on reboot
sudo tee -a /etc/rc.local > /dev/null <<EOT
/home/platypus/Code/platformplatform/platformplatform.sh start
exit 0
EOT

sudo cdmod +x /etc/rc.local
