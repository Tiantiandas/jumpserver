## 用 Docker 来构建 Jumpserver

说明: 项目从 [[ Jumpserver 官方 ]](https://github.com/jumpserver/jumpserver.git) fork 而来.
<br>

**主要更新:**

- OS: ubuntu:18.04
- 优化了 Dockerfile
- Jumpserver 版本: 1.4.0
- redis 运行在容器内
- mysql 从容器中摘离了出来
<br>

**环境依赖**

- mysql 版本: 5.7.23  (问题查看 [[ 这里 ]](https://github.com/jumpserver/jumpserver/issues/1654))
- mysql 数据库的字符编码为 : `utf8`. 
<br>

**运行容器时环境变量的缺省选项为**

```sh
DB_ENGINE=mysql
DB_HOST=172.17.0.1
DB_USER=jms
DB_PASSWORD=jumpserver
DB_NAME=jumpserver
DB_PORT=3306
```
<br><br>


### 用 Docker 来构建 Jumpserver

**准备数据库 mysql**

```sh
docker volume create jms_mysql

docker run -d --name jms_mysql \
    --restart=always \
    -p 3306:3306 \
    -v jms_mysql:/var/lib/mysql mysql:5.7.23
```
<br>

登录 mysql 创建数据库

```sh
mysql> CREATE DATABASE `jumpserver` CHARACTER SET utf8;
mysql> GRANT ALL PRIVILEGES ON `jumpserver`.* TO 'jms'@'172.17.%' IDENTIFIED BY "jumpserver";
mysql> FLUSH PRIVILEGES;
```
<br>

**创建 jumpserver 镜像**
```sh
git clone https://github.com/Tiantiandas/jumpserver.git
cd jumpserver
docker build -t xxx/jumpserver<:tag> .
```
<br>

**也可以从 dockerhub 获取**

```sh
docker pull zhegao/jumpserver:1.4.0
```
<br>

**运行 jumpserver 容器**

```bash
docker run -d --name jms_server \
    -p 8080:80 \
    -p 2222:2222 \
    -e "DB_HOST=<mysql_host>" \
    -e "DB_USER=<mysql_user>" \
    -e "DB_PASSWORD=<mysql_password>" \
    -e "DB_NAME=<mysql_dbname>" \
    -e "DB_PORT=<mysql_port>" \
    zhegao/jumpserver:1.4.0
```
<br>

**宿主机 nginx 配置**

因为 coco 是 websocket 服务, 需要指定 `Upgrade` Header 以及 `http_version`.

```lua
upstream jumpserver{
    server 127.0.0.1:8080;
}

server {
    listen 80;
    server_name  52.194.23.216;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwared-Proto "http";

    location / {
        proxy_pass http://jumpserver;
    }

    location /media/ {
        add_header Content-Encoding gzip;
        proxy_pass http://jumpserver;
    }

    location /socket.io/ {
        proxy_pass       http://jumpserver;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    error_page 404 /404.html;
        location = /40x.html {
    }
    error_page 500 502 503 504 /50x.html;
        location = /50x.html {
    }
}
```
