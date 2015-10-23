#!/usr/bin/env bash
WORKDIR=$PWD
LOGDIR=$WORKDIR'/docker/var/log'

NGINX_DIR=$WORKDIR'/nginx'
NGINX_LOG=$LOGDIR'/nginx'
HOST_CONFIG=$NGINX_DIR'/conf.d'
DATABASE_DIR=$WORKDIR'/docker/data'
PHP_LOG=$LOGDIR'/php'

DATABASE_NAME='dbtest'
DATABASE_USER='dbtest_user'
DATABASE_PASSWORD='123qwe'

HOST_CONFIG=$HOST_CONFIG
CONTAINER_CONFIG='/etc/nginx/conf.d'

XDEBUG_PORT=9001

HOST_VOLUME=$WORKDIR
CONTAINER_VOLUME='/usr/share/nginx/html'

HOST_WEB_LOG=$NGINX_LOG
CONTAINER_WEB_LOG='/var/log/nginx/'

HOST_PHP_LOG=$PHP_LOG
CONTAINER_PHP_LOG='/usr/local/lib/php5.5.28/var/log/'

CONTAINER_NAME='sfera/nginx-php-fpm:0.4'

HOST_PORT=80
CONTAINER_PORT=80

CONTAINER_SSH_PORT=22
CONTAINER_HOST_PORT=23

DATABASE_HOST_VOLUME=$WORKDIR'/db/'$DATABASE_NAME
DATABASE_CONTAINER_VOLUME='/var/www/mysql/'$DATABASE_NAME

NAME_WEB_STACK_CONTAINER='web-stack'
NAME_SQL_CONTAINER='percona-db'
NAME_NOSQL_CONTAINER='couch-db'

USER_INPUT=$1
NAME=$(basename $0)


function create_dirs {
  if [ ! -d $PHP_LOG ]; then
      mkdir -p $PHP_LOG
  fi
  if [ ! -d $NGINX_DIR ]; then
      mkdir -p $NGINX_DIR
  fi

  if [ ! -d $NGINX_LOG ]; then
      mkdir -p $NGINX_LOG
  fi

  if [ ! -d $HOST_CONFIG ]; then
      mkdir -p $HOST_CONFIG
  fi

  if [ ! -d $DATABASE_DIR ]; then
      mkdir -p $DATABASE_DIR
  fi
}

function start_containers {
  create_dirs
  #Before start container we need to remove all containers with same names with suppressing possible error messages
  docker rm $NAME_WEB_STACK_CONTAINER 2> /dev/null
  docker rm $NAME_SQL_CONTAINER 2> /dev/null
  docker rm $NAME_NOSQL_CONTAINER 2> /dev/null

  #https://hub.docker.com/_/percona/
  docker run --name=$NAME_SQL_CONTAINER  -e MYSQL_ROOT_PASSWORD=$DATABASE_PASSWORD -d percona:latest
  #https://github.com/klaemo/docker-couchdb
  docker run -d -p 5984:5984 -v /$DATABASE_DIR:/usr/local/var/lib/couchdb --name=$NAME_NOSQL_CONTAINER klaemo/couchdb

  docker run -d -p $XDEBUG_PORT:$XDEBUG_PORT -p $HOST_PORT:$CONTAINER_PORT -p $CONTAINER_HOST_PORT:$CONTAINER_SSH_PORT  \
   -v /$HOST_CONFIG:$CONTAINER_CONFIG -v /$HOST_VOLUME:$CONTAINER_VOLUME \
   -v /$HOST_WEB_LOG:$CONTAINER_WEB_LOG -v /$HOST_PHP_LOG:$CONTAINER_PHP_LOG --name=$NAME_WEB_STACK_CONTAINER \
   --link=$NAME_NOSQL_CONTAINER:dbnosql --link=$NAME_SQL_CONTAINER:dbsql $CONTAINER_NAME

  docker ps
}

function stop_containers() {
  docker kill $NAME_WEB_STACK_CONTAINER 2> /dev/null
  docker kill $NAME_SQL_CONTAINER 2> /dev/null
  docker kill $NAME_NOSQL_CONTAINER 2> /dev/null
  docker rm $NAME_WEB_STACK_CONTAINER 2> /dev/null
  docker rm $NAME_SQL_CONTAINER 2> /dev/null
  docker rm $NAME_NOSQL_CONTAINER 2> /dev/null
}

function restart_containers() {
  stop_containers
  start_containers
}

case "$USER_INPUT" in
  start)
    start_containers
  ;;
  stop)
    stop_containers
  ;;
  restart)
    restart_containers
  ;;
  *)
  echo "Usage: $NAME:{start|stop|restart}"
esac