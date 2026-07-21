FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG PHP_VERSION=8.3
ARG LOCALE=pt_BR.UTF-8

# ---------------------------------------------------------------------------
# Instalação de dependências do sistema, PPA do PHP e pacotes PHP
# Tudo em um único RUN para reduzir o número de camadas e o tamanho final
# ---------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        ca-certificates \
        gnupg \
    && add-apt-repository ppa:ondrej/php -y \
    && apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        nano \
        unzip \
        curl \
        locales \
        apache2 \
        php${PHP_VERSION} \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-xmlrpc \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-imagick \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-dev \
        php${PHP_VERSION}-imap \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-pspell \
        libapache2-mod-php${PHP_VERSION} \
    && apt-get install --reinstall -y ca-certificates \
    && locale-gen ${LOCALE} \
    && a2enmod rewrite actions headers \
    # Altera AllowOverride de None para All no diretório padrão do Apache
    && sed -i '170,174 s/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf \
    # Limpeza de cache do apt para reduzir o tamanho da imagem
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# ---------------------------------------------------------------------------
# Composer — instalador verificado via hash oficial (evita MITM no curl | php)
# ---------------------------------------------------------------------------
RUN cd /usr/local/lib && \
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    HASH="$(curl -sS https://composer.github.io/installer.sig)" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') !== '${HASH}') { unlink('composer-setup.php'); exit(1); } echo 'Composer installer verificado' . PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# ---------------------------------------------------------------------------
# Código da aplicação e permissões
# ---------------------------------------------------------------------------
WORKDIR /var/www/html/src

COPY src/ /var/www/html/src

RUN chown www-data:www-data -R /var/www/html/src && \
    chmod u=rwX,g=srX,o=rX -R /var/www/html/src && \
    find /var/www/html/src -type d -exec chmod g=rwxs "{}" \; && \
    find /var/www/html/src -type f -exec chmod g=rws "{}" \;

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]
