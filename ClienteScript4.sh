sysbench \
--db-driver=mysql \
--mysql-user=maxscale \
--mysql_password=max_passwd \
--mysql-db=sbtest \
--mysql-host=192.168.50.5 \
--mysql-port=3306 \
--tables=16 \
--table-size=10000 \
/usr/share/sysbench/oltp_read_write.lua prepare

sysbench \
--db-driver=mysql \
--mysql-user=maxscale \
--mysql_password=max_passwd \
--mysql-db=sbtest \
--mysql-host=192.168.50.5 \
--mysql-port=3306 \
--tables=16 \
--table-size=10000 \
--threads=8 \
--time=300 \
--events=0 \
--report-interval=1 \
--rate=40 \
/usr/share/sysbench/oltp_read_write.lua run