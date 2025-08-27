# 🔊 Lavalink Server (Pre-Configured)

This repository provides a **production-ready Lavalink server** configuration, designed to work seamlessly with the companion [koureidev/discord-lavalink-music-bot](https://github.com/koureidev/discord-lavalink-music-bot).

It comes pre-configured with plugins for **YouTube** and **Spotify** (via Lavasrc), along with optional support for extra YouTube tokens (POT).

⚠️ **Disclaimer**: This project is intended for educational purposes only. It does not include any credentials, nor does it provide instructions on bypassing third-party services. You are responsible for supplying your own valid API credentials.

---

## ✨ Features

* **Stable Lavalink core**: Runs the latest Lavalink release.
* **YouTube support**: OAuth-based playback for reliable streaming.
* **Spotify integration**: Handled by the Lavasrc plugin, with search and link playback.
* **Docker-ready**: Includes Dockerfile and docker-compose setup for quick deployment.
* **Customizable**: Configure via `.env` and `application.yml.template`.

---

## 🚀 Getting Started

You can run the Lavalink server in **two ways**:

### ⚡ Option A – Run with Docker (recommended)

1. **Install prerequisites:**  
   * **Docker** and **Docker Compose** must be installed. If you install Docker Desktop, compose will already be included.
     - [Install Docker](https://docs.docker.com/get-docker/)  
     - [Install Docker Compose](https://docs.docker.com/compose/install/)

2. **Clone the repository:**
   ```bash
   git clone https://github.com/koureidev/discord-lavalink-music-server.git
   cd lavalink
   ```

3. **Configure environment variables:**  
   Use `.env.example` as a reference. Copy its content into a new `.env` file and update it with your credentials.

4. **Start the server in the background:**
   ```bash
   docker compose up -d --build
   ```

5. **Check logs:**
   ```bash
   docker compose logs -f
   ```

6. **Stop the server:**
   ```bash
   docker compose down
   ```

---

### ⚡ Option B – Run locally (manual setup)

1. **Install prerequisites:**
   * **Java JDK 17.0.16+**
     - [Oracle JDK](https://www.oracle.com/java/technologies/downloads)  
     - [Microsoft OpenJDK](https://learn.microsoft.com/java/openjdk/download)  
     - Linux (Debian/Ubuntu):  
       ```bash
       sudo apt-get install openjdk-17-jdk
       ```  
     - Linux (Fedora/CentOS/Rocky):  
       ```bash
       dnf install java-17-openjdk
       ```
       or
       ```bash
       yum install java-17-openjdk
       ```

2. **Clone the repository:**
   ```bash
   git clone https://github.com/koureidev/discord-lavalink-music-server.git
   cd lavalink
   ```

3. **Set up configuration:**
   - Copy `application.yml.template` to `application.yml`.
   - Edit `application.yml` with your credentials (password, plugins, tokens, etc.).
   - Alternatively, use `.env` together with `start.sh` to auto-generate the config.

4. **Run Lavalink:**
   ```bash
   java -Xmx768m -Xms256m -jar Lavalink.jar
   ```

---

## ⚙️ Configuration Details

* **Port & Password**
  Must match the values in the bot’s `.env`. Default:
  ```env
  LAVALINK_PORT=2333
  LAVALINK_PASSWORD=youshallnotpass
  ```

* **YouTube (OAuth)**
  Requires `YOUTUBE_CLIENT_ID`, `YOUTUBE_CLIENT_SECRET`, and `YOUTUBE_REFRESH_TOKEN`.

* **Spotify (Lavasrc)**
  Requires `SPOTIFY_CLIENT_ID` and `SPOTIFY_CLIENT_SECRET`.  
  `SPOTIFY_COUNTRY` should be a valid ISO country code (e.g., US, JP, DE).

* **POT Plugin (Optional)**
  Extra tokens for YouTube playback. Not officially supported by YouTube. Leave empty unless you have them.

---

## 🙏 Acknowledgements

This project would not be possible without the incredible work of the open-source community. Special thanks to:

* **[Lavalink](https://github.com/lavalink-devs/Lavalink):** The powerful, standalone audio sending node used for all audio playback.
* **[lavalink-client](https://github.com/lavalink-devs/lavalink-client):** A feature-rich and stable Lavalink client for Node.js.
* **[Lavasrc](https://github.com/topi314/LavaSrc):** A Lavalink plugin that provides support for Spotify, Deezer, and Apple Music.
* **[youtube-source](https://github.com/lavalink-devs/youtube-source):** An official Lavalink plugin for sourcing audio from YouTube.
