FROM eclipse-temurin:21-jre

WORKDIR /app

RUN apt-get update && apt-get install -y gettext-base curl ca-certificates libstdc++6 ffmpeg git && rm -rf /var/lib/apt/lists/*

COPY application.yml.template /app/application.yml.template

ARG LAVALINK_VERSION
ADD https://github.com/lavalink-devs/Lavalink/releases/download/${LAVALINK_VERSION}/Lavalink.jar /app/Lavalink.jar
RUN printf "${LAVALINK_VERSION}" > /app/Lavalink.jar.version

RUN mkdir /app/plugins
ARG YOUTUBE_PLUGIN_VERSION
ADD https://github.com/lavalink-devs/youtube-source/releases/download/${YOUTUBE_PLUGIN_VERSION}/youtube-plugin-${YOUTUBE_PLUGIN_VERSION}.jar /app/plugins/youtube-plugin.jar
RUN printf "${YOUTUBE_PLUGIN_VERSION}" > /app/plugins/youtube-plugin.jar.version

ARG LAVASRC_PLUGIN_VERSION
ADD https://github.com/topi314/LavaSrc/releases/download/${LAVASRC_PLUGIN_VERSION}/lavasrc-plugin-${LAVASRC_PLUGIN_VERSION}.jar /app/plugins/lavasrc-plugin.jar
RUN printf "${LAVASRC_PLUGIN_VERSION}" > /app/plugins/lavasrc-plugin.jar.version

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 2333

CMD ["/app/start.sh"]
