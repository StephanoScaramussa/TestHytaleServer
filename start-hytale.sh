#!/bin/bash

# --- CONFIGURAÇÕES DE CAMINHO (Codespaces) ---
BASE_DIR="/hytale"
DOWNLOADER="$BASE_DIR/hytale-downloader-linux-amd64"
VERSION_FILE="$BASE_DIR/current_version.txt"
SERVER_JAR="$BASE_DIR/install/release/package/game/latest/hytale_server.jar"

# Garante que o downloader tenha permissão
chmod +x "$DOWNLOADER"

# --- LÓGICA DE AUTO-UPDATE ---
echo "--- Verificando atualizações ---"
LATEST_VERSION=$("$DOWNLOADER" --print-version)

if [[ -f "$VERSION_FILE" ]]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
else
    CURRENT_VERSION="none"
fi

echo "Versão instalada: $CURRENT_VERSION"
echo "Versão disponível: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
    echo "Nova versão detectada! Baixando..."
    "$DOWNLOADER"
    echo "$LATEST_VERSION" > "$VERSION_FILE"
else
    echo "O servidor já está na versão mais recente."
fi

# --- INICIAR SERVIDOR ---
echo "--- Iniciando Servidor Hytale ---"
# Ajustei a memória para 4GB, mas se seu Codespace for potente, pode aumentar.
java -Xms4G -Xmx16G -jar "$SERVER_JAR"

# --- AUTO-COMMIT E PUSH (Backup) ---
echo "--- Servidor fechado. Salvando progresso no GitHub ---"
git add .
git commit -m "Auto-save Hytale: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main # Altere para sua branch se não for main

echo "--- Tudo pronto! Codespace pode ser fechado. ---"
