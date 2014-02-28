# dominik/nginx-php
# VERSION 0.0.1
#
# BUILD: docker build --no-cache -rm -t dominik/nginx-php .
# RUN:   docker run -p $PORT:80 dominik/nginx-php

FROM ubuntu:13.10
MAINTAINER Dominik Tobschall <dominik@fruux.com>

ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) multiverse" >> /etc/apt/sources.list

RUN apt-get -y -qq update
RUN apt-get -y -qq upgrade
RUN apt-get -y -qq dist-upgrade

RUN apt-get -y --force-yes -qq install nginx \
                                       php5-fpm \
                                       php5-cli

# nginx config
ONBUILD RUN rm /etc/nginx/sites-available/default
ONBUILD RUN rm /etc/nginx/sites-enabled/default
RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original
ADD ./config/nginx/nginx.conf /etc/nginx/nginx.conf

# php config
RUN echo "cgi.fix_pathinfo = 1" >> /etc/php5/fpm/php.ini
RUN echo "output_buffering off" >> /etc/php5/fpm/php.ini
RUN echo "always_populate_raw_post_data off" >> /etc/php5/fpm/php.ini
RUN echo "magic_quotes_gpc = Off" >> /etc/php5/fpm/php.ini
RUN echo "mbstring.func_overload off" >> /etc/php5/fpm/php.ini
RUN echo "expose_php = Off" >> /etc/php5/fpm/php.ini
RUN echo "date.timezone = 'UTC'" >> /etc/php5/fpm/php.ini
RUN echo "date.timezone = 'UTC'" >> /etc/php5/cli/php.ini

# php-fpm config
RUN mv /etc/php5/fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf.original
RUN mv /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/php-fpm.conf
ADD ./config/php/fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD ./config/php/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf

# add app
ONBUILD RUN mkdir /opt/app
ONBUILD ADD . /opt/app

# vhost config
ONBUILD ADD ./config/docker/nginx/vhost.conf /etc/nginx/sites-available/app.conf
ONBUILD RUN ln -s -f /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/app.conf

EXPOSE 80

CMD service php5-fpm start && service nginx start
