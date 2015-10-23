#!/usr/bin/env bash
if [ ! -f /etc/nginx/conf.d/sites/default.conf ]; then
    echo "file not exists /etc/nginx/conf.d/sites/default.conf";
    cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/sites/default.conf
fi
php-fpm
service nginx start