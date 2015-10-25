#!/usr/bin/env bash
if [ ! -f /etc/nginx/conf.d/sites/default.conf ]; then
    cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/sites/default.conf
fi
php-fpm
nohup /usr/sbin/sshd 2> /dev/null
service nginx start
