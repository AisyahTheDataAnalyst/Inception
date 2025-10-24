FROM debian:bullseye

RUN apt update && apt install -y nginx openssl && apt clean

COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./tools/init_ssl.sh /tmp/init_ssl.sh
RUN chmod +x /tmp/init_ssl.sh && sh /tmp/init_ssl.sh

CMD ["nginx", "-g", "daemon off;"]
