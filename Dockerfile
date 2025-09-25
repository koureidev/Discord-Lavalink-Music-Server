FROM eclipse-temurin:17-jre

WORKDIR /app

RUN apt-get update && apt-get install -y gettext-base curl ca-certificates libstdc++6 ffmpeg && rm -rf /var/lib/apt/lists/*

COPY application.yml.template /app/application.yml.template

ARG LAVALINK_VERSION=4.1.1
ADD https://github.com/lavalink-devs/Lavalink/releases/download/${LAVALINK_VERSION}/Lavalink.jar /app/Lavalink.jar

RUN mkdir /app/plugins
ARG YOUTUBE_PLUGIN_VERSION=1.13.5
ADD https://github.com/lavalink-devs/youtube-source/releases/download/${YOUTUBE_PLUGIN_VERSION}/youtube-plugin-${YOUTUBE_PLUGIN_VERSION}.jar /app/plugins/youtube-plugin.jar

ARG LAVASRC_PLUGIN_VERSION=4.8.1
ADD https://github.com/topi314/LavaSrc/releases/download/${LAVASRC_PLUGIN_VERSION}/lavasrc-plugin-${LAVASRC_PLUGIN_VERSION}.jar /app/plugins/lavasrc-plugin.jar

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 2333

CMD ["/app/start.sh"]
