# extract mcrcon
FROM debian:bookworm-slim AS builder

ADD https://github.com/Tiiffi/mcrcon/releases/download/v0.7.2/mcrcon-0.7.2-linux-x86-64-static.zip /usr/bin/mcrcon.zip
RUN apt-get update && apt-get install -y unzip 

RUN unzip -j /usr/bin/mcrcon.zip -d /usr/bin/mc-rcon && chmod a+x /usr/bin/mc-rcon/mcrcon


# actual image
FROM eclipse-temurin:21

COPY --from=builder /usr/bin/mc-rcon /usr/bin/mc-rcon
COPY start-server.sh /usr/bin/start-server.sh
RUN chmod a+x /usr/bin/start-server.sh
COPY mcrcon /usr/bin/mcrcon
RUN chmod a+x /usr/bin/mcrcon
COPY template/ /defaults/

WORKDIR /minecraft_data
ENTRYPOINT ["/usr/bin/start-server.sh"]

