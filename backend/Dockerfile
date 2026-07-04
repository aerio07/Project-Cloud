# Gunakan image resmi PHP dengan Apache bawaan
FROM php:8.2-apache

# Install dependensi sistem dan ekstensi PHP yang dibutuhkan Laravel & PostgreSQL
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_pgsql pgsql

# Aktifkan Apache rewrite module untuk routing Laravel
RUN a2enmod rewrite

# Konfigurasi Apache Document Root agar mengarah ke folder public/ Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set working directory
WORKDIR /var/www/html

# Salin seluruh source code proyek
COPY . .

# Salin Composer binary dari image resmi Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Jalankan instalasi dependensi Laravel via Composer
RUN composer install --no-dev --optimize-autoloader

# Atur kepemilikan permission untuk folder storage dan bootstrap cache agar Apache bisa menulis
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Port default
EXPOSE 80

# Jalankan web server Apache di foreground
CMD ["apache2-foreground"]
