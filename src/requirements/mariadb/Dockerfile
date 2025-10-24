FROM debian:bullseye

RUN apt update && apt install -y mariadb-server && apt clean

COPY ./tools/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

CMD ["sh", "/tmp/setup.sh"]
