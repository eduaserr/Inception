FROM debian:bookworm

LABEL maintainer="eduaserr <eduaserr@student.42malaga.com>"

RUN apt-get update && \
	apt-get install -y nginx openssl curl

RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -subj "/C=ES/ST=Malaga/L=Malaga/O=42 Malaga/OU=eduaserr/CN=eduaserr" \
	-x509 -nodes -days 365 -new -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/eduaserr.42.fr.key \
	-out /etc/nginx/ssl/eduaserr.42.fr.crt

COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]

EXPOSE 443