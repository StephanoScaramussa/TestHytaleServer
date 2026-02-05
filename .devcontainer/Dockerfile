FROM mcr.microsoft.com/devcontainers/base:ubuntu

USER root

# Instala Java 25 (Adoptium Temurin) e ferramentas de sistema
RUN apt-get update && apt-get install -y wget apt-transport-https gnupg \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null \
    && echo "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update && apt-get install -y temurin-25-jdk git sudo curl \
    && rm -rf /var/lib/apt/lists/*

# Configura Identidade Git para evitar bloqueios no backup
RUN git config --global user.email "stephanoscaramussa@gmail.com" \
    && git config --global user.name "StephanoScaramussa" \
    && git config --global --add safe.directory /hytale

WORKDIR /hytale
