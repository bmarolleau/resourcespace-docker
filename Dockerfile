FROM quay.io/cybozu/ubuntu-minimal:focal-20211006
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get install -y \
    vim \
    imagemagick \
    apache2 \
    subversion \
    ghostscript \
    antiword \
    poppler-utils \
    libimage-exiftool-perl \
    cron \
    postfix \
    wget \
    php \
    php-dev \
    php-gd \
    php-mysqlnd \
    php-mbstring \
    php-zip \
    libapache2-mod-php \
    ffmpeg \
    libopencv-dev \
    python3-opencv \
    python3 \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 10G/g" /etc/php/7.4/apache2/php.ini                                                      
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 10G/g" /etc/php/7.4/apache2/php.ini                                                                  
RUN sed -i -e "s/max_execution_time\s*=\s*30/max_execution_time = 10000/g" /etc/php/7.4/apache2/php.ini                                                      
RUN sed -i -e "s/memory_limit\s*=\s*128M/memory_limit = 4G/g" /etc/php/7.4/apache2/php.ini

RUN printf '<Directory /var/www/>\n\
\tOptions FollowSymLinks\n\
</Directory>\n'\
>> /etc/apache2/sites-enabled/000-default.conf

ADD cronjob /etc/cron.daily/resourcespace

WORKDIR /var/www/html
RUN rm index.html
RUN svn co https://svn.resourcespace.com/svn/rs/releases/9.7 .
RUN mkdir filestore
RUN chmod 777 filestore
RUN chmod -R 777 include/
EXPOSE 8080 8443
RUN sed -i -e 's/80/8080/g' -e 's/443/8443/g' /etc/apache2/ports.conf
WORKDIR /var
RUN chown -R 1001:0 .
USER 1001
ENV APACHE_SERVER_NAME=__default__
CMD apachectl -D FOREGROUND
