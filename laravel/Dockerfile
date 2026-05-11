FROM php:8.4-cli-alpine

RUN apk add --no-cache sqlite sqlite-dev \
    && docker-php-ext-install pdo pdo_sqlite

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install --no-interaction --optimize-autoloader \
    && cp .env.example .env \
    && php artisan key:generate \
    && mkdir -p database \
    && touch database/database.sqlite \
    && echo "DB_DATABASE=/app/database/database.sqlite" >> .env \
    && php artisan migrate --no-interaction

EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
