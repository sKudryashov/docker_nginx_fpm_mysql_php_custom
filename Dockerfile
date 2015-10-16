FROM debian:8.2
MAINTAINER s.a.kudryashov@gmail.com

#WGET, CURL, PEAR, PHING, MC, VIM, LOCATE, SUPERVISOR installation
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y apt-utils
RUN apt-get update -y && apt-get install --no-install-recommends -y -q curl build-essential ca-certificates git
RUN apt-get install php-pear -y && pear channel-update pear.php.net && pear upgrade pear && \
    pear channel-discover pear.phing.info && pear install --alldeps phing/phing
RUN apt-get install -y apt-utils mc vim wget locate supervisor


#PHP additional packages installation
ADD ./php-installer /opt/php-installer
RUN apt-get install -y libxml2-dev libssl-dev libcurl4-openssl-dev pkg-config libvpx-dev libjpeg62-turbo-dev libpng12-dev \
    libfreetype6-dev libicu-dev libreadline-dev libxslt1-dev libgearman-dev autoconf re2c

#PHP engine compilation
RUN cd /opt/php-installer && ./php-installer install

#Making php-installer global
RUN ln -s /opt/php-installer/php-installer /usr/bin/php-installer


RUN apt-get install -y libmemcached-dev && php-installer extension memcached

RUN apt-get install -y cmake build-essential fakeroot devscripts dpkg-dev

RUN wget -O- http://packages.couchbase.com/ubuntu/couchbase.key | apt-key add -
RUN wget -O/etc/apt/sources.list.d/couchbase.list http://packages.couchbase.com/ubuntu/couchbase-ubuntu1204.list
RUN apt-get update && apt-get install -y libcouchbase2-libevent libcouchbase-dev libjpeg62-turbo-dev
#RUN php-installer setup

RUN apt-get install -y imagemagick imagemagick-common libmagickwand-dev imagemagick-doc && \
    cd /usr/bin && ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/Wand-config && \
    ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/Magick-config && \
    ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config

#And then set-up additional extensions
RUN php-installer extension gearman
RUN php-installer extension xdebug
RUN php-installer extension pcntl
RUN php-installer extension pthreads
RUN php-installer extension http
RUN php-installer extension couchbase
RUN php-installer extension raphf
RUN php-installer extension propro
RUN php-installer extension imagick
RUN php-installer configure
RUN php-installer update

RUN export TERM=xterm

#NGINX installation
RUN wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key && \
    echo 'deb http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list && \
    echo 'deb-src http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list && \
    apt-get update -y && apt-get install -y nginx
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log
ADD assets/launch.sh

EXPOSE 9000
EXPOSE 9001
EXPOSE 443
EXPOSE 80
EXPOSE 22

CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["launch.sh"]
