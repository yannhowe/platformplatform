#!/bin/bash
#exclude ubuntu updates
sudo tar --exclude='/home/platypus/Code/platformplatform/apt-mirror/data' -czvf /upd02/platformbundle.zip  /home/platypus/Code/platformplatform/
#exclude ubuntu updates
sudo tar --exclude='/home/platypus/Code/platformplatform/apt-mirror/data' -czvf /mnt/pleco/minio-txout/platformbundle.zip  /home/platypus/Code/platformplatform/
#Move from ext to dev
cp -p /home/platypus/Code/platformplatform/apt-mirror/data /mnt/pleco/minio-tx
#rsync incremental from ext to internal
sudo rsync -zarvh /home/platypus/Code/platformplatform/apt-mirror/data /upd02/
