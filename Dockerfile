FROM ubuntu:latest

LABEL MAINTAINER="Ralph Göstenmeier"

#
RUN apt-get --yes update
RUN apt-get --yes upgrade

# set environment variables
ENV TZ 'Europe/Berlin'

RUN echo $TZ > /etc/timezone 

RUN apt-get install -y tzdata
RUN rm /etc/localtime && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata 
RUN apt-get clean

RUN apt-get install --yes software-properties-common build-essential lsb-release wget curl sudo git vim unzip
RUN apt-get install --yes python3-pip python3-venv

RUN add-apt-repository ppa:ondrej/php
RUN apt-get install --yes php8.0  php8.0-xml php-mbstring php-sqlite3
RUN phpenmod mbstring

#RUN    wget https://www.apachefriends.org/xampp-files/8.0.8/xampp-linux-x64-8.0.8-1-installer.run \
#    && chmod +x xampp-linux-x64-8.0.8-1-installer.run \
#    && ./xampp-linux-x64-8.0.8-1-installer.run

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install --yes nodejs

RUN npm -g update npm
RUN npm -g install yarn npm-check-updates

ARG USERHOME=/home/user

# Create User and gave him sudo permissions
RUN groupadd work -g 1000 && adduser user --uid 1000 --gid 1000 --home $USERHOME --disabled-password --gecos User
RUN echo '%work        ALL=(ALL)       NOPASSWD: ALL' >/etc/sudoers.d/work

# -----------------------------------------------------------------------------
USER user

VOLUME [ "/workspace" ]
WORKDIR /workspace
#RUN chown user /workspace && chmod 775 /workspace

# Add composer installed files to path
RUN echo "\n\nPATH=$PATH:/home/user/bin:/home/user/.config/composer/vendor/bin" >>~/.bashrc

# Install composer
RUN    mkdir $USERHOME/bin \
    && cd    $USERHOME/bin \
    && curl -sS https://getcomposer.org/installer -o installer \
    && php installer --filename composer

# Install Larvel installer
RUN $USERHOME/bin/composer global require "laravel/installer"

#
RUN echo "laravel new site --jet --stack livewire --teams" > $USERHOME/bin/install_laravel-app
RUN echo "php artisan serve --host 0.0.0.0" > $USERHOME/bin/run_server
RUN echo "npm install && npm run dev" > $USERHOME/bin/run_build
RUN chmod +x ${USERHOME}/bin/run*

#
EXPOSE 3000 
EXPOSE 8000

CMD ["bash", "-l"]
