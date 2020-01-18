FROM spritsail/alpine:3.11

ARG MC_VER=1.7.10
ARG FORGE_VER=10.13.4.1558
ARG BUILD_VER=${MC_VER}-${FORGE_VER}
ARG JAR_FILE=forge-${BUILD_VER}.jar

LABEL maintainer="Spritsail <minecraftforge@spritsail.io>" \
      org.label-schema.name="Minecraft Forge server" \
      org.label-schema.url="http://files.minecraftforge.net/" \
      org.label-schema.description="Minecraft Forge server" \
      org.label-schema.version=${MC_VER}-${FORGE_VER}

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
    rm -f forge-*.log && \
    rm -rf /tmp/*

WORKDIR /mc

ENV INIT_MEM=1G \
    MAX_MEM=4G \
    SERVER_JAR=/forge/${JAR_FILE}

CMD exec java "-Xms$INIT_MEM" "-Xmx$MAX_MEM" -jar "$SERVER_JAR" nogui
