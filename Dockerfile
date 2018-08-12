FROM ubuntu:18.04
WORKDIR /opt
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && \
    apt-get -y install tzdata apt-utils language-pack-zh-hans&& \
    apt-get -y install python3 python3-pip libmysqlclient-dev sshpass \
        nginx redis supervisor  python-tk python-dev \
        libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev \
        libwebp-dev tcl8.5-dev tk8.5-dev  openssl libssl-dev libldap2-dev \
        libsasl2-dev libkrb5-dev vim net-tools && \
    echo 'LANG="zh_CN.UTF-8"' > /etc/default/locale

COPY jumpserver jumpserver
COPY coco coco
RUN pip3 install -r jumpserver/requirements/requirements.txt && \
    pip3 install -r coco/requirements/requirements.txt

VOLUME /opt/luna
VOLUME /opt/coco/keys
VOLUME /opt/jumpserver/data

# 7. 准备文件
COPY luna luna
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

ENV DB_ENGINE=mysql \
    DB_HOST=172.17.0.1 \
    DB_PORT=3306 \
    DB_USER=jms \
    DB_PASSWORD=jumpserver \
    DB_NAME=jumpserver \
    REDIS_HOST=127.0.0.1 \
    REDIS_PORT=6379 

EXPOSE 2222 80
ENTRYPOINT ["entrypoint.sh"]

