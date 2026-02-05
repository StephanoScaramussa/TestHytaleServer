#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="/hytale"
DOWNLOADER="$BASE_DIR/hytale-downloader-linux-amd64"
VERSION_FILE="$BASE_DIR/current_version.txt"

cd "$SCRIPT_DIR"

# 1. Auto-Update inicial
chmod +x "$DOWNLOADER"
LATEST_VERSION=$("$DOWNLOADER" -print-version)
CURRENT_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "none")

if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
    echo "[Launcher] Versão nova detectada: $LATEST_VERSION. Atualizando..."
    "$DOWNLOADER"
    echo "$LATEST_VERSION" > "$VERSION_FILE"
fi

# 2. Loop de execução (Baseado no start.sh oficial)
while true; do
    APPLIED_UPDATE=false

    # Aplica updates pendentes do downloader
    if [ -f "updater/staging/Server/HytaleServer.jar" ]; then
        echo "[Launcher] Aplicando patches pendentes..."
        cp -f updater/staging/Server/HytaleServer.jar Server/
        [ -f "updater/staging/Server/HytaleServer.aot" ] && cp -f updater/staging/Server/HytaleServer.aot Server/
        [ -d "updater/staging/Server/Licenses" ] && rm -rf Server/Licenses && cp -r updater/staging/Server/Licenses Server/
        [ -f "updater/staging/Assets.zip" ] && cp -f updater/staging/Assets.zip ./
        rm -rf updater/staging
        APPLIED_UPDATE=true
    fi

    # Entra na pasta Server para rodar e gerar logs/mundos lá dentro
    if [ -d "Server" ]; then
        cd Server
    else
        echo "[Launcher] Erro: Pasta Server não encontrada. Rode o downloader primeiro."
        exit 1
    fi

    # Configuração Java: 16GB RAM + Cache AOT
    JVM_ARGS="-Xms16G -Xmx16G"
    [ -f "HytaleServer.aot" ] && JVM_ARGS="$JVM_ARGS -XX:AOTCache=HytaleServer.aot"

    # Argumentos do Servidor (Sem Sentry conforme pedido)
    DEFAULT_ARGS="--assets ../Assets.zip --backup --backup-dir backups --backup-frequency 30 --disable-sentry"

    echo "[Launcher] Iniciando Servidor Hytale..."
    java $JVM_ARGS -jar HytaleServer.jar $DEFAULT_ARGS "$@"
    
    EXIT_CODE=$?

    # Volta para a raiz para backup ou restart
    cd "$SCRIPT_DIR"

    # Se o servidor fechar pedindo update (Code 8)
    if [ $EXIT_CODE -eq 8 ]; then
        echo "[Launcher] Reiniciando para aplicar atualização..."
        continue
    fi

    # Backup final antes de desligar
    echo "[Launcher] Servidor encerrado. Sincronizando arquivos com GitHub..."
    git add .
    git commit -m "Hytale Auto-save: $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    
    break
done
