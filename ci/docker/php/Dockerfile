FROM composer

ARG sample

RUN mkdir -p /work/server/php
WORKDIR /work/server/php

COPY ${sample}/server/php/composer.* /work/server/php/
RUN composer install -q

COPY ${sample}/client /work/client
COPY ${sample}/server/php /work/server/php
