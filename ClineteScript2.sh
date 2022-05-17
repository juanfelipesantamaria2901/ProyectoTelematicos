sudo systemctl start mariadb
sudo systemctl enable mariadb
mariadb --host=192.168.50.5 \
   --port=3306 \
   --user=maxscale \
   --password=maxs_passwd  