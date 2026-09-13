FROM debian:bookworm

LABEL maintainer="eduaserr <eduaserr@student.42malaga.com>"

RUN apt-get update && \
    apt-get install -y \
		default-mysql-client \
    	php8.2 \
		php8.2.cli \
		php8.2-fpm \
		php8.2-mysql \
		php8.2-curl \
		php8.2-mbstring \
		php8.2-zip \
		php8.2-xml \
		php8.2-redis \
		wget \
		curl \
		unzip

RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html
WORKDIR /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

COPY ./tools/config.sh .
RUN chmod +x config.sh

EXPOSE 9443

CMD [ "sh", "config.sh" ]
