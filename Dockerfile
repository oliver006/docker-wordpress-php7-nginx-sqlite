FROM phusion/baseimage:0.9.18
MAINTAINER Oliver <oliver@21zoo.com>

CMD ["/sbin/my_init"]

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y  --force-yes software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update

# Basic Requirements
RUN apt-get -y --force-yes install nginx php7.0 php7.0-fpm php7.0-mysql pwgen python-setuptools curl git unzip

# Wordpress Requirements
RUN apt-get -y --force-yes install php7.0-curl php7.0-gd php7.0-intl php-pear php7.0-imap php7.0-ps php7.0-pspell php7.0-recode php7.0-sqlite php7.0-tidy php7.0-xmlrpc php7.0-xsl

RUN apt-get install -y --force-yes php-memcached
RUN apt-get purge -y --force-yes php5 php5-common
RUN apt-get --purge autoremove -y

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.0/fpm/pool.d/www.conf
RUN find /etc/php/7.0/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;
RUN mkdir /run/php
RUN touch /var/log/php7.0-fpm.log

# nginx site conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default

# Supervisor Config
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# Install Wordpress
ADD https://wordpress.org/latest.tar.gz /usr/share/nginx/latest.tar.gz
RUN cd /usr/share/nginx/ && tar xvf latest.tar.gz && rm latest.tar.gz
RUN mv /usr/share/nginx/html/5* /usr/share/nginx/wordpress
RUN rm -rf /usr/share/nginx/www
RUN mv /usr/share/nginx/wordpress /usr/share/nginx/www
ADD https://downloads.wordpress.org/plugin/wordpress-php-info.zip /usr/share/nginx/www/wp-content/plugins/wordpress-php-info.zip
RUN cd /usr/share/nginx/www/wp-content/plugins/ && unzip wordpress-php-info.zip && rm wordpress-php-info.zip

ADD https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip /tmp/sqlite-integration.1.8.1.zip
RUN cd /tmp/ && unzip sqlite-integration.1.8.1.zip && rm sqlite-integration.1.8.1.zip
RUN cd /tmp/ && mv sqlite-integration /usr/share/nginx/www/wp-content/plugins/ && cp /usr/share/nginx/www/wp-content/plugins/sqlite-integration/db.php /usr/share/nginx/www/wp-content/ 

RUN chown -R www-data:www-data /usr/share/nginx/www

# Wordpress Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
EXPOSE 80

# volume for sqlite and wordpress install
VOLUME ["/usr/share/nginx/www/wp-content/database/", "/usr/share/nginx/www"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/bin/bash", "/start.sh"]

