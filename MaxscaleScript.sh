sudo -i
sudo yum -y install wget tree vim python3
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup

echo "b2064eff25a3553845ccb58dcb21b6a7dc83cebfe4815f33de37cf7e2a4bf165 mariadb_repo_setup" \
> | sha256sum -c -

chmod +x mariadb_repo_setup

sudo ./mariadb_repo_setup \
   --mariadb-maxscale-version="2.5"
     
sudo yum -y install maxscale  