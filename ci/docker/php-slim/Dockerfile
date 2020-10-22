FROM composer

ARG sample

RUN mkdir -p /work/server/php-slim
WORKDIR /work/server/php-slim

COPY ${sample}/server/php-slim/composer.* /work/server/php-slim/
RUN composer install -q

COPY ${sample}/client /work/client
COPY ${sample}/server/php-slim /work/server/php-slim
