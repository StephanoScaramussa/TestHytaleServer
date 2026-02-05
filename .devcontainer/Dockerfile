# Usamos uma base que facilite a instalação do Java 25
FROM mcr.microsoft.com/devcontainers/base:ubuntu

USER root
# Instalar Java 25 (Temurin), Git e Sudo
RUN apt-get update && apt-get install -y wget apt-transport-https gnupg \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null \
    && echo "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update && apt-get install -y temurin-25-jdk git sudo curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /hytale
