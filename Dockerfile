#FROM debian:8.2
FROM sfera/php-base-custom:0.1

RUN apt-get update -y

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

#Tweaking php config a bit
RUN sed -i -e '1 a\;=== Errors handling ===========================================================================' /usr/local/lib/php5.5.28/etc/php.ini
RUN sed -i -e '2 a\display_errors = On' /usr/local/lib/php5.5.28/etc/php.ini
RUN sed -i -e '3 a\display_startup_errors = On' /usr/local/lib/php5.5.28/etc/php.ini
RUN sed -i -e '4 a\error_log = /var/log/php/php_errors.log' /usr/local/lib/php5.5.28/etc/php.ini
RUN sed -i -e '4 a\error_reporting = E_ALL' /usr/local/lib/php5.5.28/etc/php.ini

# Supervisor Config
ADD assets/supervisord.conf /etc/supervisord.conf

RUN echo 'root:000999' | chpasswd

#SSH service
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV export NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
ADD assets/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key
ADD assets/ssh/ssh_host_dsa_key.pub /etc/ssh/ssh_host_dsa_key.pub
ADD assets/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ecdsa_key
ADD assets/ssh/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ecdsa_key.pub
ADD assets/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
ADD assets/ssh/ssh_host_ed25519_key.pub /etc/ssh/ssh_host_ed25519_key.pub
ADD assets/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
ADD assets/ssh/ssh_host_rsa_key.pub /etc/ssh/ssh_host_rsa_key.pub

RUN cd /etc/ssh/ && chmod 644 $(ls | grep .pub) && chmod 600 moduli && chmod 644 ssh_config \
    && chmod 600 ssh_host_dsa_key && chmod 600 ssh_host_ecdsa_key && chmod 600 ssh_host_rsa_key \
    && chmod 600 ssh_host_ed25519_key && chmod 640 sshd_config

#ssh root@127.0.0.1 -p 23


EXPOSE 9000
EXPOSE 9001
EXPOSE 443
EXPOSE 80
EXPOSE 22

#USER nginx

ENTRYPOINT ["./launch.sh"]

