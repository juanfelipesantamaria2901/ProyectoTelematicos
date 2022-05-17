# ProyectoTelematicos
Acontinuacion presentamos una pequeña guia de como usar el aprovisionamiento de nuestro repositorio para la implementación de un balanceador de base de datos
aquí encontrarás la configuracion vagrantfile inicial, la configuracion de los archivos para maxscale y mariadb tanto para el MasterSQL como para el SlaveSQL 
también encontrarás un archivo con las instruciones SQL de cada servidor y los scripts.sh para el aprovicionamiento y como usarlos en tu configuración vagrantfile.
```ruby
Vagrant.configure("2") do |config|

  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
  end

  config.vm.define :clienteCentOS2 do |clienteCentOS2|
    clienteCentOS2.vm.box = "bento/centos-7.9"
    clienteCentOS2.vm.network :private_network, ip: "192.168.50.6"
    clienteCentOS2.vm.hostname = "clienteCentOS2"
    config.vm.synced_folder ".", "/vagrant/Nombre"
    config.vm.provision "shell", path: "ClienteScript.sh"
    end

  config.vm.define :masterSQL do |masterSQL|
    masterSQL.vm.box = "bento/centos-7.9"
    masterSQL.vm.network :private_network, ip: "192.168.50.7"
    masterSQL.vm.hostname = "masterSQL"
    config.vm.synced_folder ".", "/vagrant/Nombre"
    config.vm.provision "shell", path: "MasterSQLscript.sh"
    end

  config.vm.define :slaveSQL do |slaveSQL|
    slaveSQL.vm.box = "bento/centos-7.9"
    slaveSQL.vm.network :private_network, ip: "192.168.50.4"
    slaveSQL.vm.hostname = "slaveSQL"
    config.vm.synced_folder ".", "/vagrant/Nombre"
    config.vm.provision "shell", path: "SlaveSQLscript.sh"
    end
        
  config.vm.define :maxscale do |maxscale|
    maxscale.vm.box = "bento/centos-7.9"
    maxscale.vm.network :private_network, ip: "192.168.50.5"
    maxscale.vm.hostname = "maxscale"
    config.vm.synced_folder ".", "/vagrant/Nombre"
    config.vm.provision "shell", path: "MaxscaleScript.sh"
    end
  end
```
El código presentado anteriormente es para configurar los script.sh en su vagrantfile solo copie y pegue, posteriormente en su terminal ejecute los comandos
```shell
vagrant up
vagrant provision
```
Recurde que los script configuran una primera parte, para las sentencias SQL debe seguir el paso a paso las siguientes lineas ⚟ sin slatarse ninguna y en el
mismo orden que se oresentaran a continuación: <br/> <br/>
<b>Para el MasterSQL</b></br>
Una vez tenga éste ejecute el siguiente comando para clonar el repositorio en la máquina 
```shell
git clone https://github.com/juanfelipesantamaria2901/ProyectoTelematicos.git 
```
Ahora diríjase a la carpeta 🗂 resultante y ejecute el script MasterSQLscript2.sh
```shell
chmod 755 MasterSQLscript2.sh
/MasterSQLscript2.sh
```
esto dara como resultado que vea una ventana de vim en ella debe pegar lo siguiente y depsues usando "ctrl + c" y ":wq" guardé 
```shell
[mariadb]

# Server Configuration
log_error                 = mariadbd.err
innodb_buffer_pool_size   = 1G

# Replication Configuration (Primary Server)
log_bin          = mariadb-bin
server_id        = 1
binlog_format    = ROW
```
Ahora diríjase a la carpeta 🗂 git y ejecute el script MasterSQLscript3.sh
```shell
chmod 755 MasterSQLscript3.sh
/MasterSQLscript3.sh
```
Como resultado vera mariadb, ahora debera pegar las siguientes sentencias  
```sql
CREATE USER repl@'%' IDENTIFIED BY 'repl_passwd';
GRANT REPLICATION SLAVE ON *.* TO repl@'%';
SHOW MASTER STATUS;
```
Ahora cierre mariadb y ejecute el script MasterSQLscript4.sh
```shell
chmod 755 MasterSQLscript4.sh
/MasterSQLscript4.sh
```
<b>Para el SlaveSQL</b></br>
ya que tiene el reposotorio clonado en el MasterSQL tiene que hacer lo mismo en el SlaveSQL y ejecutar el script SlaveSQLscript2.sh
```shell
git clone https://github.com/juanfelipesantamaria2901/ProyectoTelematicos.git
chmod 755 SlaveSQLscript2.sh
/SlaveSQLscript2.sh
``` 
Ahora en la ventana vim que se abrio pegue lo siguiente y use la combinaciones de teclas "ctrl + c" y ":wq" para guardar 
```shell
[mariadb]

# Server Configuration
log_error                 = mariadbd.err
innodb_buffer_pool_size   = 1G

# Replication Configuration (Replica Server)
log_bin                = mariadb-bin
server_id              = 2
log_slave_updates      = ON
binlog_format          = ROW
```
Antes de seguir debe ir a el MasterSQL y pegar el siguiente comando
```shell
sudo rsync -av /data/backup/replica_backup 192.168.50.4:/data/backup/
```
<b>Regrese al SlaveSQL</b></br>
Ahora ejecute el script SlaveSQLscript3.sh 
```shell
chmod 755 SlaveSQLscript3.sh
/SlaveSQLscript3.sh
``` 
Una vez hecho esto debe en el mariadb de SlaveSQL poner las siguientes sentencias 
```sql
 SET GLOBAL gtid_slave_pos='0-1-2';
CHANGE MASTER TO
   MASTER_USER = "repl",
   MASTER_HOST = "192.168.50.7",
   MASTER_PASSWORD = "repl_passwd",
   MASTER_USE_GTID=slave_pos;
START SLAVE; 
SHOW SLAVE STATUS\G
```
<b>Regrese al MasterSQL</b>
```sql
CREATE DATABASE IF NOT EXISTS test;

CREATE TABLE test.names (
   id INT PRIMARY KEY AUTO_INCREMENT,
   name VARCHAR(255));

INSERT INTO test.names(name) VALUES
   ("Walker Percy"), ("Kate Chopin"), ("William Faulkner"), ("Jane Austen");

SELECT * FROM test.names;   
```
<b>Regrese al SlaveSQL</b>
```sql
use test;
desc test.names;
SELECT * FROM test.names;
```
<b>Regrese a la maquina MasterSQL</b></br>
Ejecute el comando 
```shell
sudo mariadb
```
Posteriormente pegue las sentencias siguientes
```sql
CREATE USER 'maxscale'@'%'
   IDENTIFIED BY 'max_passwd';

GRANT SHOW DATABASES ON *.*
     TO 'maxscale'@'%';
GRANT SELECT ON mysql.columns_priv
     TO 'maxscale'@'%';
GRANT SELECT ON mysql.db
     TO 'maxscale'@'%';
GRANT SELECT ON mysql.proxies_priv
     TO 'maxscale'@'%';
GRANT SELECT ON mysql.roles_mapping
     TO 'maxscale'@'%';
GRANT SELECT ON mysql.tables_priv
     TO 'maxscale'@'%';
GRANT SELECT ON mysql.user
     TO 'maxscale'@'%';
     
GRANT BINLOG ADMIN,
   READ_ONLY ADMIN,
   RELOAD,
   REPLICA MONITOR,
   REPLICATION MASTER ADMIN,
   REPLICATION REPLICA ADMIN,
   REPLICATION REPLICA,
   SHOW DATABASES
   ON *.*
   TO 'maxscale'@'%';     
```
<b>Para el Maxscale</b></br>
Ejecute el siguiente comando 
```shell
vim /etc/maxscale.cnf
```
En la ventana vim que se abre debe remplazar todo y pegar lo siguiente 
```shell
[maxscale]
admin_auth=true

[server1]
type=server
address=192.168.50.7
port=3306
protocol=MariaDBBackend

[server2]
type=server
address=192.168.50.4
port=3306
protocol=MariaDBBackend

[repl-monitor]
type          = monitor
module        = mariadbmon
servers       = server1,server2
user          = maxscale
password      = max_passwd
auto_failover = ON
auto_rejoin   = ON


[split-router]
type     = service
router   = readwritesplit
servers  = server1,server2
user     = maxscale
password = max_passwd

[split-router-listener]
type     = listener
service  = split-router
protocol = MariaDBClient
port     = 3306
```
Guarde con "ctrl + c" y ":wq" y ahora colone el repositorio y ejecute el el script MaxscaleScript2.sh
```shell
git clone https://github.com/juanfelipesantamaria2901/ProyectoTelematicos.git
chmod 755 MaxscaleScript2.sh
/MaxscaleScript2.sh
```
<b>Para el cliente</b></br>
En el cliente debe hacer lo siguente primero clone el repositorio y ejecute el script ClineteScript2.sh
```shell
git clone https://github.com/juanfelipesantamaria2901/ProyectoTelematicos.git
chmod 755 ClineteScript2.sh
/ClineteScript2.sh
```
En el mariadb debe pegar las siguientes sentencias
```shell
SELECT @@server_id AS "Server ID";

use test;
CREATE TABLE test.readwrite_test (
   id INT PRIMARY KEY AUTO_INCREMENT,
   write_id INT
);

INSERT INTO test.readwrite_test (write_id) VALUES (@@server_id);
INSERT INTO test.readwrite_test (write_id) VALUES (@@server_id);
INSERT INTO test.readwrite_test (write_id) VALUES (@@server_id);

SELECT readwrite.id AS "Primary Key",
   current.id AS "Current Server ID",
   readwrite.write_id AS "Stored Server ID"
FROM (
   SELECT @@server_id AS id
) AS current
INNER JOIN (
   SELECT id, write_id
   FROM test.readwrite_test
) AS readwrite;
```
Ahora ejecuta el script ClineteScript3.sh
```shell
chmod 755 ClineteScript3.sh
/ClineteScript3.sh
```
<b>Regresa al MasterSQL</b></br>
Ejecuta la siguiente sentencia en el mariadb
```sql
create database sbtest;
grant all on sbtest.* to 'maxscale'@'%';
show grants for maxscale;
create user sbtest_user identified by ‘password’
grant all on sbtest.* to 'sbtest_user'@'%';
```
<b>Regresa al cliente</b></br>
Ahora ejecuta el script ClineteScript4.sh
```shell
chmod 755 ClineteScript4.sh
/ClineteScript4.sh
```
y con eso tendras toda la configuracion necesaria. Si quieres ver la guia completa o ir por los vagrant box, puedes encontrar la guia en el siguiente enlace 🔗 
<a herf = "https://juanfelipest.atlassian.net/l/c/XvQvY3B1"> Guia Completa </a></br>
Los vagrant box los encontraras en el enlace 🔗 </br>
<a herf = "https://app.vagrantup.com/cfarinavalencia/"> Vagrant Boxes </a></br>
También encontras un artículo sobre los balanceos de carga en servidores de bases de datos en el siguiente enlace 🔗 </br>
<a herf = "https://juanfelipest.atlassian.net/l/c/qcwqwL4V"> Artículo </a></br>

