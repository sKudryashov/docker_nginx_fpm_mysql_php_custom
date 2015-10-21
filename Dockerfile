#FROM debian:8.2
FROM sfera/php-base-custom:0.1

#NGINX installation
RUN wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key && \
    echo 'deb http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list && \
    echo 'deb-src http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list && \
    apt-get update -y && apt-get install -y nginx

RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

RUN php-installer update

ADD assets/launch.sh launch.sh
RUN chmod g+x launch.sh

ADD assets/nginx/nginx.conf /etc/nginx/nginx.conf
ADD assets/nginx/server /etc/nginx/server
ADD assets/nginx/conf.d /etc/nginx/conf.d
ADD assets/php-test/index.php /usr/share/nginx/html/
RUN chown -R nginx:nginx /etc/nginx/

RUN usermod -a -G root nginx && usermod -a -G adm nginx && chmod g+w /var/log/nginx/ \
 && chmod g+w /var/log/nginx/access.log && chmod g+w /var/log/nginx/error.log

# Supervisor Config
ADD assets/supervisord.conf /etc/supervisord.conf

EXPOSE 9000
EXPOSE 9001
EXPOSE 443
EXPOSE 80
EXPOSE 22

ENTRYPOINT ["./launch.sh"]

