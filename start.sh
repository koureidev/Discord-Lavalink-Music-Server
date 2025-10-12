#!/bin/sh
CIPHER_PID=""
cleanup() {
    echo "Shutting down servers..."
    if [ -n "$CIPHER_PID" ]; then
        kill "$CIPHER_PID" 2>/dev/null
    fi
    exit 0
}
trap cleanup INT TERM

check_and_download() {
    FILE_PATH=$1
    TARGET_VERSION=$2
    DOWNLOAD_URL=$3
    VERSION_FILE="${FILE_PATH}.version"

    CURRENT_VERSION=""
    if [ -f "$VERSION_FILE" ]; then
        CURRENT_VERSION=$(cat "$VERSION_FILE")
    fi

    if [ ! -f "$FILE_PATH" ] || [ "$CURRENT_VERSION" != "$TARGET_VERSION" ]; then
        if [ -f /.dockerenv ]; then
            echo "FATAL: $(basename "$FILE_PATH") is outdated or missing inside the Docker image." >&2
            echo "       Target version: ${TARGET_VERSION}, but found version: ${CURRENT_VERSION:-'none'}." >&2
            echo "       Please rebuild the Docker image with 'docker compose up --build'." >&2
            exit 1
        else
            echo "$(basename "$FILE_PATH") is outdated or missing. Downloading version ${TARGET_VERSION}..."
            rm -f "$FILE_PATH" "$VERSION_FILE"
\            curl -SL -o "$FILE_PATH" "$DOWNLOAD_URL"
            echo "${TARGET_VERSION}" > "$VERSION_FILE"
            echo "Download complete."
        fi
    fi
}

set -e

for cmd in curl java envsubst git; do
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

if [ -f /.dockerenv ]; then
    if echo "${CIPHER_SERVER_URL}" | grep -qE "localhost|127\.0\.0\.1|0\.0\.0\.0|192\.168\."; then
        export CIPHER_SERVER_URL="http://cipher-server:8001/"
        echo "[INFO] Docker detected: Overriding local cipher URL to ${CIPHER_SERVER_URL}"
    fi
fi

if echo "${CIPHER_SERVER_URL}" | grep -qE "localhost|127\.0\.0\.1|192\.168\."; then
    echo "Self-hosted cipher server selected. Starting setup..."

    if ! command -v "deno" >/dev/null 2>&1; then
        echo "Error: 'deno' command not found. It is required for the self-hosted cipher server." >&2
        echo "Please see the README for installation instructions." >&2
        exit 1
    fi

    YT_CIPHER_DIR="$SCRIPT_DIR/yt-cipher"
    if [ ! -d "$YT_CIPHER_DIR" ]; then
        echo "Cloning yt-cipher repository..."
        git clone https://github.com/kikkia/yt-cipher.git "$YT_CIPHER_DIR"

        echo "Setting up yt-cipher dependency (ejs)..."
        (
            cd "$YT_CIPHER_DIR"
            git clone https://github.com/yt-dlp/ejs.git
            cd ejs
            git checkout 689764f8cea694e99609a41f1630d2e7e8e8668a
            cd ..
            # The patch script may not be necessary for most setups but is good practice
            if [ -f "./scripts/patch-ejs.ts" ]; then
                deno run --allow-read --allow-write ./scripts/patch-ejs.ts
            fi
        )
    fi

    echo "Starting yt-cipher server in the background..."
    (
    cd "$YT_CIPHER_DIR"

    echo "Caching/installing yt-cipher dependencies (full tree)..."
    deno cache --reload --node-modules-dir server.ts

    echo "Dependencies ready. Starting server..."
    API_TOKEN="${CIPHER_SERVER_PASSWORD}" PORT=8001 \
        deno run --allow-net --allow-read --allow-write --allow-env server.ts

    ) &
    CIPHER_PID=$!
    echo "Cipher server started with PID: $CIPHER_PID"
    sleep 3
fi

: "${LAVALINK_VERSION:=4.1.1}"
: "${YOUTUBE_PLUGIN_VERSION:=1.15.0}"
: "${LAVASRC_PLUGIN_VERSION:=4.8.1}"

LAVALINK_JAR="$SCRIPT_DIR/Lavalink.jar"
PLUGINS_DIR="$SCRIPT_DIR/plugins"
YOUTUBE_PLUGIN_JAR="$SCRIPT_DIR/plugins/youtube-plugin.jar"
LAVASRC_PLUGIN_JAR="$SCRIPT_DIR/plugins/lavasrc-plugin.jar"
TEMPLATE_FILE="$SCRIPT_DIR/application.yml.template"
OUTPUT_FILE="$SCRIPT_DIR/application.yml"

LAVALINK_URL="https://github.com/lavalink-devs/Lavalink/releases/download/${LAVALINK_VERSION}/Lavalink.jar"
YOUTUBE_PLUGIN_URL="https://github.com/lavalink-devs/youtube-source/releases/download/${YOUTUBE_PLUGIN_VERSION}/youtube-plugin-${YOUTUBE_PLUGIN_VERSION}.jar"
LAVASRC_PLUGIN_URL="https://github.com/topi314/LavaSrc/releases/download/${LAVASRC_PLUGIN_VERSION}/lavasrc-plugin-${LAVASRC_PLUGIN_VERSION}.jar"

mkdir -p "$PLUGINS_DIR"
check_and_download "$LAVALINK_JAR" "$LAVALINK_VERSION" "$LAVALINK_URL"
check_and_download "$YOUTUBE_PLUGIN_JAR" "$YOUTUBE_PLUGIN_VERSION" "$YOUTUBE_PLUGIN_URL"
check_and_download "$LAVASRC_PLUGIN_JAR" "$LAVASRC_PLUGIN_VERSION" "$LAVASRC_PLUGIN_URL"

echo "Generating application.yml from template..."

envsubst '$LAVALINK_PORT,$LAVALINK_PASSWORD,$CIPHER_SERVER_URL,$CIPHER_SERVER_PASSWORD,$YOUTUBE_CLIENT_ID,$YOUTUBE_CLIENT_SECRET,$YOUTUBE_REFRESH_TOKEN,$POT_TOKEN,$POT_VISITOR_DATA,$SPOTIFY_CLIENT_ID,$SPOTIFY_CLIENT_SECRET,$SPOTIFY_COUNTRY' < "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "Configuration file created."

echo "Starting Lavalink server..."
exec java -Xmx768m -Xms256m -jar "$LAVALINK_JAR"
