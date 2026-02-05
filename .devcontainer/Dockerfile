FROM mcr.microsoft.com/devcontainers/base:ubuntu

USER root

# Instala Java 25, Git, Sudo e GIT-LFS
RUN apt-get update && apt-get install -y wget apt-transport-https gnupg \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null \
    && echo "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update && apt-get install -y temurin-25-jdk git git-lfs sudo curl \
    && rm -rf /var/lib/apt/lists/*

# Configura o Git e inicializa o LFS
RUN git config --global user.email "hytale-server@codespace.com" \
    && git config --global user.name "Hytale Server Auto-Backup" \
    && git config --global --add safe.directory /hytale \
    && git lfs install

WORKDIR /hytale
