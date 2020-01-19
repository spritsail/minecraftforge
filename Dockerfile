FROM spritsail/alpine:3.11

ARG MC_VER=1.7.10
ARG FORGE_VER=10.13.4.1558
ARG BUILD_VER=${MC_VER}-${FORGE_VER}-${MC_VER}

LABEL maintainer="Spritsail <minecraftforge@spritsail.io>" \
      org.label-schema.name="Minecraft Forge server" \
      org.label-schema.url="http://files.minecraftforge.net/" \
      org.label-schema.description="Minecraft Forge server" \
      org.label-schema.version=${MC_VER}

RUN apk --no-cache add openjdk8-jre nss && \
    \
    cd /tmp && \
    wget -O forge-installer.jar \
        https://files.minecraftforge.net/maven/net/minecraftforge/forge/${BUILD_VER}/forge-${BUILD_VER}-installer.jar && \
    \
    mkdir /forge && \
    cd /forge && \
    java -jar /tmp/forge-installer.jar --installServer && \
    # Remove the log, we don't want it
    rm -f forge-${BUILD_VER}-installer.jar.log && \
    rm -rf /tmp/*

WORKDIR /mc

ENV INIT_MEM=1G \
    MAX_MEM=4G \
    SERVER_JAR=/forge/forge-${BUILD_VER}-universal.jar

CMD exec java "-Xms$INIT_MEM" "-Xmx$MAX_MEM" -jar "$SERVER_JAR" nogui
