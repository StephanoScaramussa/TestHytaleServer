#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="/hytale"
DOWNLOADER="$BASE_DIR/hytale-downloader-linux-amd64"
VERSION_FILE="$BASE_DIR/current_version.txt"

cd "$SCRIPT_DIR"

# 1. Permissões e Update inicial
chmod +x "$DOWNLOADER"
echo "[Launcher] Verificando versão..."
LATEST_VERSION=$("$DOWNLOADER" -print-version)
CURRENT_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "none")

if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
    echo "[Launcher] Nova versão disponível: $LATEST_VERSION. Atualizando..."
    "$DOWNLOADER"
    echo "$LATEST_VERSION" > "$VERSION_FILE"
fi

# 2. Loop de execução
while true; do
    # Aplica patches se o downloader deixou algo preparado
    if [ -f "updater/staging/Server/HytaleServer.jar" ]; then
        echo "[Launcher] Aplicando patches oficiais..."
        cp -f updater/staging/Server/HytaleServer.jar Server/
        [ -f "updater/staging/Server/HytaleServer.aot" ] && cp -f updater/staging/Server/HytaleServer.aot Server/
        [ -d "updater/staging/Server/Licenses" ] && rm -rf Server/Licenses && cp -r updater/staging/Server/Licenses Server/
        [ -f "updater/staging/Assets.zip" ] && cp -f updater/staging/Assets.zip ./
        rm -rf updater/staging
    fi

    if [ ! -d "Server" ]; then echo "[Launcher] Erro: Pasta Server não encontrada!"; exit 1; fi
    cd Server

    # Java 25 + 16GB RAM + AOT
    JVM_ARGS="-Xms6G -Xmx14G"
    [ -f "HytaleServer.aot" ] && JVM_ARGS="$JVM_ARGS -XX:AOTCache=HytaleServer.aot"
    
    # Argumentos do Hytale
    DEFAULT_ARGS="--assets ../Assets.zip --backup --backup-dir backups --backup-frequency 30 --disable-sentry"

    echo "[Launcher] Iniciando Servidor Hytale..."
    java $JVM_ARGS -jar HytaleServer.jar $DEFAULT_ARGS "$@"
    
    EXIT_CODE=$?
    cd "$SCRIPT_DIR"

    if [ $EXIT_CODE -eq 8 ]; then
        echo "[Launcher] Reiniciando para atualizar..."
        continue
    fi

    # 3. Backup Git Verboso
    echo "[Launcher] Servidor encerrado. Sincronizando com GitHub..."
    git config --global --add safe.directory /hytale
    git add .
    
    if ! git diff-index --quiet HEAD --; then
        echo "[Launcher] Mudanças detectadas. Fazendo commit..."
        git commit -m "Auto-save Hytale: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "[Launcher] Enviando para o repositório..."
        git push origin main
    else
        echo "[Launcher] Nada novo para salvar."
    fi
    
    break
done
