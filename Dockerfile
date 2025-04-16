FROM php:8.4-fpm
# Installer les dépendances
RUN apt-get update && apt-get install -y \
    nginx \
    wget \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libcurl4-openssl-dev \
    libbz2-dev \
    supervisor \
    && docker-php-ext-install pdo_mysql zip mbstring intl xml curl gd bz2 opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Créer le répertoire web
RUN mkdir -p /var/www/html

# Copier l'application
COPY --chown=www-data:www-data ./src/ /var/www/html/

# Copier la config nginx
COPY ./nginx/default.conf /etc/nginx/sites-available/default

# Copier la config supervisor
COPY ./supervisord.conf /etc/supervisord.conf

# Répertoire de travail
WORKDIR /var/www/html

# Exposer le port HTTP
EXPOSE 80

# Démarrer supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
