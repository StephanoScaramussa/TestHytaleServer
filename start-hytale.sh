#!/bin/bash

# --- CONFIGURAÇÕES ---
BASE_DIR="/hytale"
DOWNLOADER="$BASE_DIR/hytale-downloader-linux-amd64"
VERSION_FILE="$BASE_DIR/current_version.txt"
# Conforme o manual, o binário e assets ficam na raiz ou pasta Server
# Vamos garantir que estamos no lugar certo
cd "$BASE_DIR"

chmod +x "$DOWNLOADER"

# --- LÓGICA DE AUTO-UPDATE ---
echo "--- Verificando atualizações (Hytale API) ---"
LATEST_VERSION=$("$DOWNLOADER" -print-version)

if [[ -f "$VERSION_FILE" ]]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
else
    CURRENT_VERSION="none"
fi

echo "Versão local: $CURRENT_VERSION | Versão remota: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
    echo "Nova build detectada! Iniciando download..."
    "$DOWNLOADER" # Executa o download oficial
    echo "$LATEST_VERSION" > "$VERSION_FILE"
    echo "Update concluído com sucesso."
else
    echo "Servidor já está na versão mais recente. Pulando download."
fi

# --- INICIAR SERVIDOR ---
echo "--- Iniciando Servidor Hytale (16GB RAM | Sem Sentry) ---"
# -Xms16G e -Xmx16G para fixar a RAM
# --disable-sentry conforme o manual oficial
# --assets Assets.zip para carregar os dados do jogo
java -XX:AOTCache=HytaleServer.aot -Xms16G -Xmx16G -jar HytaleServer.jar --assets Assets.zip --disable-sentry

# --- BACKUP PÓS-DESLIGAMENTO ---
echo "--- Servidor encerrado. Sincronizando com GitHub ---"
git add .
git commit -m "Hytale Auto-save: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main # Certifique-se de que sua branch é a 'main'

echo "--- Backup concluído. Até a próxima! ---"
