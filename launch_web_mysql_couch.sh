#!/usr/bin/env bash
WORKDIR=$PWD
NGINX_LOG=$WORKDIR'/nginx/log/'
HOST_CONFIG=$WORKDIR'/conf.d/'
DATABASE_DIR=$WORKDIR'/data'

DATABASE_NAME='dbtest'
DATABASE_USER='dbtest_user'
DATABASE_PASSWORD='123qwe'

HOST_CONFIG=$HOST_CONFIG
CONTAINER_CONFIG='/etc/nginx/conf.d/'

XDEBUG_PORT=9001

HOST_VOLUME=$WORKDIR
CONTAINER_VOLUME='/usr/share/nginx/html'

HOST_WEB_LOG=$NGINX_LOG
CONTAINER_WEB_LOG=/var/log/nginx/

CONTAINER_NAME='sfera/nginx-php-fpm:0.3'

HOST_PORT=81
CONTAINER_PORT=80

DATABASE_HOST_VOLUME=$WORKDIR'/db/'$DATABASE_NAME'/'
DATABASE_CONTAINER_VOLUME='/var/www/mysql/'$DATABASE_NAME'/'

NAME_WEB_STACK_CONTAINER='web-stack'
NAME_SQL_CONTAINER='percona-db'
NAME_NOSQL_CONTAINER='couch-db'

USER_INPUT=$1
NAME=$(basename $0)


function start_containers { # {{{
  #Before start container we need to remove all containers with same names with suppressing possible error messages
  docker rm $NAME_WEB_STACK_CONTAINER 2> /dev/null
  docker rm $NAME_SQL_CONTAINER 2> /dev/null
  docker rm $NAME_NOSQL_CONTAINER 2> /dev/null

  #https://hub.docker.com/_/percona/
  docker run --rm --name=$NAME_SQL_CONTAINER -e DBNAME=$DATABASE_NAME -e DBUSER=$DATABASE_USER -e DBPASS=$DATABASE_PASSWORD \
 nicescale/percona-mysql /opt/nicedocker/create_db.sh

  docker run -d -p 5984:5984 -v $DATABASE_DIR:/usr/local/var/lib/couchdb --name=$NAME_NOSQL_CONTAINER klaemo/couchdb

  docker run -d -p $XDEBUG_PORT:$XDEBUG_PORT -p $HOST_PORT:$CONTAINER_PORT -v $HOST_CONFIG:$CONTAINER_CONFIG -v \
  $HOST_VOLUME:$CONTAINER_VOLUME -v $HOST_WEB_LOG:$CONTAINER_WEB_LOG --name=$NAME_WEB_STACK_CONTAINER \
    --link=$NAME_NOSQL_CONTAINER:dbnosql $CONTAINER_NAME

  docker ps
} # }}}

function stop_containers() { # {{{
  docker kill $NAME_WEB_STACK_CONTAINER 2> /dev/null
  docker kill $NAME_SQL_CONTAINER 2> /dev/null
  docker kill $NAME_NOSQL_CONTAINER 2> /dev/null
  docker rm $NAME_WEB_STACK_CONTAINER 2> /dev/null
  docker rm $NAME_SQL_CONTAINER 2> /dev/null
  docker rm $NAME_NOSQL_CONTAINER 2> /dev/null
} # }}}

function restart_containers() { # {{{
  stop_containers
  start_containers
} # }}}

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
