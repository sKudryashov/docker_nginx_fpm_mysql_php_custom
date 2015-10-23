#!/usr/bin/env bash
if [ ! -f /etc/nginx/conf.d/sites/default.conf ]; then
    cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/sites/default.conf
fi
php-fpm
service nginx start
/usr/sbin/sshd -D