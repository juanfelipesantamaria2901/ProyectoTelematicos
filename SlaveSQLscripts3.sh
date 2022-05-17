rm -rf /var/lib/mysql

sudo mariadb-backup --copy-back \
   --target-dir=/data/backup/replica_backup

ls /data/backup/

tree /data

sudo chown -R mysql:mysql /var/lib/mysql
cd /data/backup/replica_backup
cat xtrabackup_binlog_info
sudo systemctl start mariadb
sudo systemctl enable mariadb
