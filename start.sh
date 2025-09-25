#!/bin/sh
set -e

for cmd in curl java envsubst; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: Command '$cmd' not found." >&2
        echo "Please ensure it is installed and available in your PATH." >&2
        if [ "$cmd" = "envsubst" ]; then
            echo "Tip: 'envsubst' is part of the 'gettext' package (e.g., 'sudo apt install gettext-base')." >&2
        fi
        exit 1
    fi
done

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$SCRIPT_DIR/.env"
  set +a
fi

: "${LAVALINK_VERSION:=4.1.1}"
: "${YOUTUBE_PLUGIN_VERSION:=1.13.5}"
: "${LAVASRC_PLUGIN_VERSION:=4.8.1}"
: "${YOUTUBE_CLIENTS:=TV,TVHTML5EMBEDDED}"

LAVALINK_JAR="$SCRIPT_DIR/Lavalink.jar"
PLUGINS_DIR="$SCRIPT_DIR/plugins"
YOUTUBE_PLUGIN_JAR="$SCRIPT_DIR/plugins/youtube-plugin.jar"
LAVASRC_PLUGIN_JAR="$SCRIPT_DIR/plugins/lavasrc-plugin.jar"
TEMPLATE_FILE="$SCRIPT_DIR/application.yml.template"
OUTPUT_FILE="$SCRIPT_DIR/application.yml"

LAVALINK_URL="https://github.com/lavalink-devs/Lavalink/releases/download/${LAVALINK_VERSION}/Lavalink.jar"
YOUTUBE_PLUGIN_URL="https://github.com/lavalink-devs/youtube-source/releases/download/${YOUTUBE_PLUGIN_VERSION}/youtube-plugin-${YOUTUBE_PLUGIN_VERSION}.jar"
LAVASRC_PLUGIN_URL="https://github.com/topi314/LavaSrc/releases/download/${LAVASRC_PLUGIN_VERSION}/lavasrc-plugin-${LAVASRC_PLUGIN_VERSION}.jar"

if [ ! -f "$LAVALINK_JAR" ]; then
    echo "Lavalink.jar not found. Downloading version ${LAVALINK_VERSION}..."
    curl -sSL -o "$LAVALINK_JAR" "$LAVALINK_URL"
    echo "Download complete."
fi

mkdir -p "$PLUGINS_DIR"

if [ ! -f "$YOUTUBE_PLUGIN_JAR" ]; then
    echo "YouTube plugin not found. Downloading version ${YOUTUBE_PLUGIN_VERSION}..."
    curl -sSL -o "$YOUTUBE_PLUGIN_JAR" "$YOUTUBE_PLUGIN_URL"
    echo "Download complete."
fi

if [ ! -f "$LAVASRC_PLUGIN_JAR" ]; then
    echo "Lavasrc plugin not found. Downloading version ${LAVASRC_PLUGIN_VERSION}..."
    curl -sSL -o "$LAVASRC_PLUGIN_JAR" "$LAVASRC_PLUGIN_URL"
    echo "Download complete."
fi

echo "Generating application.yml from template..."

export YOUTUBE_CLIENTS_YAML=$(printf '      - %s\n' $(echo "$YOUTUBE_CLIENTS" | tr ',' ' '))

envsubst '$LAVALINK_PORT,$LAVALINK_PASSWORD,$YOUTUBE_CLIENT_ID,$YOUTUBE_CLIENT_SECRET,$YOUTUBE_REFRESH_TOKEN,$POT_TOKEN,$POT_VISITOR_DATA,$SPOTIFY_CLIENT_ID,$SPOTIFY_CLIENT_SECRET,$SPOTIFY_COUNTRY,$YOUTUBE_CLIENTS_YAML' < "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "Configuration file created."

echo "Starting Lavalink server..."
exec java -Xmx768m -Xms256m -jar "$LAVALINK_JAR"
