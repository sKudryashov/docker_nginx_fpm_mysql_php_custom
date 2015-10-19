#FROM debian:8.2
FROM sfera/php-base-custom:0.1

#NGINX installation
RUN wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key && \
    echo 'deb http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list && \
    echo 'deb-src http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list && \
    apt-get update -y && apt-get install -y nginx
#RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

RUN php-installer update

ADD assets/launch.sh launch.sh
ADD assets /home/assets
RUN export TERM=xterm && chmod a+x launch.sh
RUN rm -rf /etc/nginx/nginx.conf
RUN rm -rf /etc/nginx/conf.d
RUN chmod 0777 -R /etc/nginx/*
RUN cp -r /home/assets/nginx/* /etc/nginx/
RUN cp -r /home/assets/php-test/index.php /usr/share/nginx/html/index.php
RUN usermod -a -G root nginx && usermod -a -G adm nginx && chmod g+w /var/log/nginx/ \
 && chmod g+w /var/log/nginx/access.log && chmod g+w /var/log/nginx/error.log

EXPOSE 9000
EXPOSE 9001
EXPOSE 443
EXPOSE 80
EXPOSE 22

ENTRYPOINT ["./launch.sh"]
#CMD ["nginx", "-g", "daemon off;"]

