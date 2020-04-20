#!/bin/bash
#export list of docker images used
docker images | tail -n +2 | awk '{print $1":"$2}' > /home/platypus/Code/platformplatform/scripts/images
#export images as tar 
sudo /home/platypus/Code/platformplatform/scripts/dockerimage_export.sh
#exclude ubuntu updates for downstream networks
cd /home/platypus/Code/
sudo tar --exclude='platformplatform/apt-mirror/data' -czvf /tmp/platformbundle.tar.gz  platformplatform/
sudo cp -p /tmp/platformbundle.tar.gz /upd02/
sudo cp -p /tmp/platformbundle.tar.gz /mnt/pleco/minio-txout/
sudo rsync -zarvh /home/platypus/Code/platformplatform/apt-mirror/data/* /mnt/pleco/minio-txout/ubuntu_data
#rsync incremental from ext to internal
sudo rsync -zarvh /home/platypus/Code/platformplatform/apt-mirror/data/* /upd02/ubuntu_data
