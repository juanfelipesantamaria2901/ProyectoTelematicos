sudo mariadb-backup --backup \
      --user=root \
      --password=vagrant \
      --target-dir=/data/backup/replica_backup

sudo mariadb-backup --prepare \
      --target-dir=/data/backup/replica_backup      


 ls /data/backup
