FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye

# set version label
ARG BUILD_DATE
ARG CODIUM_VERSION
ARG OBSIDIAN_VERSION
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=POD

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    chromium \
    desktop-file-utils \
    fonts-noto-color-emoji \
    git \
    gnome-keyring \
    libatspi2.0-0 \
    libgtk-3-0 \
    libnotify4 \
    libnss3 \
    libsecret-1-0 \
    ssh-askpass \
    stterm \
    thunar && \
  echo "**** install codium ****" && \
  if [ -z ${CODIUM_VERSION+x} ]; then \
    CODIUM_VERSION=$(curl -sX GET "https://api.github.com/repos/VSCodium/vscodium/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/codium.deb -L \
    "https://github.com/VSCodium/vscodium/releases/download/${CODIUM_VERSION}/codium_${CODIUM_VERSION}_amd64.deb" && \
  apt install --no-install-recommends -y /tmp/codium.deb && \
  echo "**** install obsidian ****" && \
  if [ -z ${OBSIDIAN_VERSION+x} ]; then \
    OBSIDIAN_VERSION=$(curl -sX GET "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest" \
    | awk '/"name"/{print $4;exit}' FS='[""]'); \
  fi && \
  curl --location --output obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb" && \
  dpkg -i obsidian.deb  && \
  echo "**** container tweaks ****" && \
  mv \
    /usr/bin/chromium \
    /usr/bin/chromium-real && \
  sed -i 's|</applications>|  <application title="VSCodium" type="normal">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config