FROM ghcr.io/machinastudios/hytale

# Instala sudo, git e dependências comuns de rede/processo
# Nota: Usamos apt-get pois a maioria das imagens de servidor de jogos usa Debian/Ubuntu
USER root
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Permite que o usuário root use sudo sem senha (útil no Codespaces)
RUN echo "root ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopasswd

# Define o diretório de trabalho
WORKDIR /hytale
