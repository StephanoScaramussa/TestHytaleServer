FROM ghcr.io/machinastudios/hytale

# Instalando ferramentas de sistema que o README não inclui por padrão
USER root
RUN apt-get update && apt-get install -y sudo git curl && rm -rf /var/lib/apt/lists/*
RUN echo "root ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopasswd

WORKDIR /hytale
