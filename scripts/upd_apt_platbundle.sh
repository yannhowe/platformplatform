#!/bin/bash
#exclude ubuntu updates
sudo tar --exclude='/home/platypus/Code/platformplatform/apt-mirror/data' -czvf /upd02/platformbundle.tar.gz  /home/platypus/Code/platformplatform/
#exclude ubuntu updates
sudo tar --exclude='/home/platypus/Code/platformplatform/apt-mirror/data' -czvf /mnt/pleco/minio-txout/platformbundle.tar.gz  /home/platypus/Code/platformplatform/
#Move from ext to dev
sudo rsync -zarvh /home/platypus/Code/platformplatform/apt-mirror/data/* /mnt/pleco/minio-txout/ubuntu_data
#rsync incremental from ext to internal
sudo rsync -zarvh /home/platypus/Code/platformplatform/apt-mirror/data/* /upd02/ubuntu_data
