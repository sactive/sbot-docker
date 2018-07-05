> we have provided a mattermost image for you , here we take Mysql for an example and you can use your own database.

## pull mysql image
```bash
docker pull mysql:5.6
```
## start mysql container
```bash
docker run -p 3306:3306 --name my-mysql -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.6
```
## go into mysql cotainer and create database
```bash
docker ps -a //find the container id
docker exec -it <container id> /bin/bash

mysqladmin -u root -p create mattermost
Enter password:******* //${MYSQL_ROOT_PASSWORD} 123456
\q
mysql -u root -p
Enter password:******* //${MYSQL_ROOT_PASSWORD} 123456
```

**start mattermost. replace the {host ip},{cert path},{cert file path},{key file path}**


> **cert file and key file should under the directory of certs path**

**Example**:

There're `cert.pem` and `key.pem` under `/root/certs`

`/root/certs` mount on the directory of `/etc/opt/certs` in container:

- `/etc/opt/certs/cert.pem`

- `/etc/opt/certs/key.pem`

## if you want to use the mattermost image we provide , you can see below command.
```bash
docker run --name mm -p 8065:8065 \
 --link=my-mysql:db \
 -e MM_SQLSETTINGS_DRIVERNAME=mysql \
 -e MM_SQLSETTINGS_DATASOURCE="root:123456@tcp(my-mysql:3306)/mattermost?charset=utf8mb4,utf8&readTimeout=30s&writeTimeout=30s" \
 -e DB_HOST=my-mysql \
 -e DB_PORT_NUMBER=3306 \
 -e MM_CERT_FILE=/etc/opt/certs/{cert file name} \
 -e MM_KEY_FILE=/etc/opt/certs/{key file name} \
 -v your certs path:/etc/opt/certs \
 -d shipengqi/sactive-matermost-poc:latest
```
**You can set proxy sa the following:**
```bash
docker run --name mm -p 8065:8065 \
 --link=my-mysql:db \
 -e MM_SQLSETTINGS_DRIVERNAME=mysql \
 -e MM_SQLSETTINGS_DATASOURCE="root:123456@tcp(my-mysql:3306)/mattermost?charset=utf8mb4,utf8&readTimeout=30s&writeTimeout=30s" \
 -e DB_HOST=my-mysql \
 -e DB_PORT_NUMBER=3306 \
 -e MM_CERT_FILE=/etc/opt/certs/cert.pem \
 -e MM_KEY_FILE=/etc/opt/certs/key.pem \
 -e http_proxy={your proxy} \
 -e https_proxy={your proxy} \
 -e HTTP_PROXY={your proxy} \
 -e HTTPS_PROXY={your proxy} \
 -e no_proxy={no proxy} \
 -e NO_PROXY={no proxy} \
 -v /root/certs:/etc/opt/certs \
 -d shipengqi/sactive-matermost-poc:latest
```
