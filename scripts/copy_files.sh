mc find minio_host/tx-out --name '*' | sed 's/minio_host\/tx-out\///g' | xargs -i mc mv minio_host/tx-out/"{}" /mnt/pleco/minio-txout/"{}"
