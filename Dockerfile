# CSS Soccer Server
# Extends base CSS server with Soccer Mod, maps, and content

ARG BASE_IMAGE=ghcr.io/quixomatic/css-server:latest
FROM ${BASE_IMAGE}

LABEL maintainer="quixomatic"
LABEL org.label-schema.description="Counter-Strike: Source Soccer Server with Soccer Mod"
LABEL org.label-schema.url="https://github.com/Quixomatic/css-soccer-server"

# Soccer Mod version to install (use 'latest' or specific version like 'v1.4.12')
ARG SOCCER_MOD_VERSION=latest

USER root

# Install unzip and jq for JSON parsing
RUN apt-get update && apt-get install -y --no-install-recommends unzip jq && rm -rf /var/lib/apt/lists/*

USER steam
WORKDIR /home/steam

# Resolve actual version tag if 'latest' is specified
# This gets the real version number (e.g., v1.4.12) for proper filename matching
RUN if [ "$SOCCER_MOD_VERSION" = "latest" ]; then \
        ACTUAL_VERSION=$(wget -qO- https://api.github.com/repos/Quixomatic/soccer-mod/releases/latest | jq -r .tag_name); \
    else \
        ACTUAL_VERSION="$SOCCER_MOD_VERSION"; \
    fi && \
    echo "Soccer Mod version: ${ACTUAL_VERSION}" && \
    echo "$ACTUAL_VERSION" > /tmp/soccer_mod_version.txt

# Download and install Soccer Mod from GitHub releases
RUN ACTUAL_VERSION=$(cat /tmp/soccer_mod_version.txt) && \
    DOWNLOAD_URL="https://github.com/Quixomatic/soccer-mod/releases/download/${ACTUAL_VERSION}" && \
    echo "Downloading Soccer Mod from ${DOWNLOAD_URL}..." && \
    wget -q "${DOWNLOAD_URL}/soccer-mod-${ACTUAL_VERSION}.zip" -O /tmp/soccer_mod.zip && \
    unzip -o /tmp/soccer_mod.zip -d /home/steam/css/cstrike/ && \
    rm /tmp/soccer_mod.zip && \
    echo "Soccer Mod installed"

# Download and install maps from GitHub releases
RUN ACTUAL_VERSION=$(cat /tmp/soccer_mod_version.txt) && \
    DOWNLOAD_URL="https://github.com/Quixomatic/soccer-mod/releases/download/${ACTUAL_VERSION}" && \
    echo "Downloading maps from ${DOWNLOAD_URL}..." && \
    wget -q "${DOWNLOAD_URL}/maps-${ACTUAL_VERSION}.zip" -O /tmp/maps.zip && \
    unzip -o /tmp/maps.zip -d /home/steam/css/cstrike/maps/ && \
    rm /tmp/maps.zip && \
    echo "Maps installed"

# Download and install skins from GitHub releases
RUN ACTUAL_VERSION=$(cat /tmp/soccer_mod_version.txt) && \
    DOWNLOAD_URL="https://github.com/Quixomatic/soccer-mod/releases/download/${ACTUAL_VERSION}" && \
    echo "Downloading skins from ${DOWNLOAD_URL}..." && \
    wget -q "${DOWNLOAD_URL}/skins-${ACTUAL_VERSION}.zip" -O /tmp/skins.zip && \
    unzip -o /tmp/skins.zip -d /home/steam/css/cstrike/ && \
    rm /tmp/skins.zip && \
    echo "Skins installed"

# Copy custom server configs (soccer-optimized settings)
# Materials, models, and sounds come from the soccer-mod release above
COPY --chown=steam:steam content/cfg/ /home/steam/css/cstrike/cfg/

# Copy soccer-specific entrypoint
COPY --chown=steam:steam scripts/entrypoint.sh /home/steam/entrypoint.sh
RUN chmod +x /home/steam/entrypoint.sh

# Update defaults backup for volume initialization
# This allows empty mounted volumes to be populated with defaults on first run
RUN mkdir -p /home/steam/css-defaults && \
    cp -r /home/steam/css/cstrike/cfg /home/steam/css-defaults/ && \
    cp -r /home/steam/css/cstrike/addons /home/steam/css-defaults/ && \
    cp -r /home/steam/css/cstrike/maps /home/steam/css-defaults/ && \
    cp -r /home/steam/css/cstrike/materials /home/steam/css-defaults/ && \
    cp -r /home/steam/css/cstrike/models /home/steam/css-defaults/ && \
    cp -r /home/steam/css/cstrike/sound /home/steam/css-defaults/

# Soccer-specific defaults
ENV CSS_HOSTNAME="CSS Soccer Server"
ENV CSS_MAP="soccer_psl_breezeway_fix"
ENV CSS_MAXPLAYERS="14"
ENV CSS_TICKRATE="100"

ENTRYPOINT ["/home/steam/entrypoint.sh"]
