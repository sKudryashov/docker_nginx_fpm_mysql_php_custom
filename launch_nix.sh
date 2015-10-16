#!/usr/bin/env bash
#DATABASE_NAME='application'
HOST_CONFIG=$PWD'/conf-d/'
CONTAINER_CONFIG='/etc/nginx/conf-d/'
XDEBUG_PORT=9001
HOST_VOLUME=$PWD
CONTAINER_VOLUME='/etc/nginx/html'
HOST_WEB_LOG=$PWD
CONTAINER_WEB_LOG=/var/log/nginx/
CONTAINER_NAME='sfera/nginx-php-fpm:0.2'
HOST_PORT=81
CONTAINER_PORT=80
#DATABASE_HOST_VOLUME=$PWD'./db/'$DATABASE_NAME'/'
#DATABASE_CONTAINER_VOLUME='/var/www/mysql/'$DATABASE_NAME'/'

docker run -d -p $XDEBUG_PORT:$XDEBUG_PORT -p $HOST_PORT:$CONTAINER_PORT -v $HOST_CONFIG:$CONTAINER_CONFIG \
 -v $HOST_VOLUME:$CONTAINER_VOLUME -v $HOST_WEB_LOG:$CONTAINER_WEB_LOG $CONTAINER_NAME