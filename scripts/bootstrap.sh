sudo apt update

sudo apt install cifs-utils nfs-common unzip pwgen dos2unix -y

curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group so you don't need to sudo 
sudo usermod -aG docker $user

export kubectl_version=1.15.5
export docker_compose_version=1.25.4
export pks_version=1.6.1
export helm_version=3.1.1
export velero_version=1.2.0

echo "Installing 'pks' v${pks_version}" \
&&   sudo wget -cO /usr/local/bin/pks https://github.com/yannhowe/docker-pks-cli/raw/master/pks_cli/pks-linux-amd64-1.6.1 \
&&   sudo chmod 0755 /usr/local/bin/pks \
&&   pks --version \
&&   echo "Installing 'kubectl' v${kubectl_version}" \
&&   sudo wget -cO /usr/local/bin/kubectl  https://storage.googleapis.com/kubernetes-release/release/v${kubectl_version}/bin/linux/amd64/kubectl \
&&   sudo chmod 0755 /usr/local/bin/kubectl \
&&   kubectl version --client \
&&   echo "Installing 'docker-compose' v${docker_compose_version}" \
&&   sudo wget -cO /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-$(uname -s)-$(uname -m) \
&&   sudo chmod 0755 /usr/local/bin/docker-compose \
&&   docker-compose --version \
&&   echo "Installing 'helm' v${helm_version}" \
&&   sudo wget -c https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz \
&&   sudo tar -zxvf helm-v${helm_version}-linux-amd64.tar.gz \
&&   sudo chmod 0755 ./linux-amd64/helm \
&&   sudo mv ./linux-amd64/helm /usr/local/bin/helm \
&&   sudo rm -rf helm-v${helm_version}-linux-amd64.tar.gz ./linux-amd64/ \
&&   helm \
&&   echo "Installing 'velero' v${velero_version}" \
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

sudo tee -a /etc/hosts > /dev/null <<EOT
127.0.0.1      platform.net
127.0.0.1      registry.platform.net
127.0.0.1      minio.platform.net
127.0.0.1      gitlab.platform.net
127.0.0.1      harbor.platform.net
127.0.0.1      apt-mirror.platform.net
127.0.0.1      airflow.platform.net
EOT