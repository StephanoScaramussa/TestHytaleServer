#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="/hytale"
DOWNLOADER="$BASE_DIR/hytale-downloader-linux-amd64"
VERSION_FILE="$BASE_DIR/current_version.txt"

cd "$SCRIPT_DIR"

# 1. Permissões e Update inicial
chmod +x "$DOWNLOADER"
echo "[Launcher] Verificando versão remota..."
LATEST_VERSION=$("$DOWNLOADER" -print-version)
CURRENT_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "none")

if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
    echo "[Launcher] Nova versão disponível: $LATEST_VERSION. Atualizando..."
    "$DOWNLOADER"
    echo "$LATEST_VERSION" > "$VERSION_FILE"
    
    # LIMPEZA SEGURA: Apaga zips de update, mas PROTEGE o Assets.zip essencial
    echo "[Launcher] Limpando arquivos temporários..."
    find . -maxdepth 1 -name "*.zip" ! -name "Assets.zip" -delete
    rm -rf updater/backup
fi

# 2. Loop de execução (Lógica oficial Hypixel)
while true; do
    # Aplica patches staged se o downloader deixou algo preparado
    if [ -f "updater/staging/Server/HytaleServer.jar" ]; then
        echo "[Launcher] Aplicando patches pendentes..."
        cp -f updater/staging/Server/HytaleServer.jar Server/
        [ -f "updater/staging/Server/HytaleServer.aot" ] && cp -f updater/staging/Server/HytaleServer.aot Server/
        [ -d "updater/staging/Server/Licenses" ] && rm -rf Server/Licenses && cp -r updater/staging/Server/Licenses Server/
        [ -f "updater/staging/Assets.zip" ] && cp -f updater/staging/Assets.zip ./
        rm -rf updater/staging
    fi

    if [ ! -d "Server" ]; then echo "[Launcher] Erro: Pasta Server não encontrada!"; exit 1; fi
    cd Server

    # JVM: 16GB RAM + AOT Cache
    JVM_ARGS="-Xms6G -Xmx14G"
    [ -f "HytaleServer.aot" ] && JVM_ARGS="$JVM_ARGS -XX:AOTCache=HytaleServer.aot"
    
    # Argumentos Hytale: Sem Sentry e Assets na pasta pai
    DEFAULT_ARGS="--assets ../Assets.zip --backup --backup-dir backups --backup-frequency 30 --disable-sentry"

    echo "[Launcher] Iniciando Servidor Hytale..."
    java $JVM_ARGS -jar HytaleServer.jar $DEFAULT_ARGS "$@"
    
    EXIT_CODE=$?
    cd "$SCRIPT_DIR"

    # Se o servidor fechar pedindo update (Code 8)
    if [ $EXIT_CODE -eq 8 ]; then
        echo "[Launcher] Reiniciando para aplicar atualização..."
        continue
    fi

    # 3. Backup Git Verboso
    echo "[Launcher] Servidor encerrado. Sincronizando com GitHub..."
    git config --global --add safe.directory /hytale
    
    # Limpa zips residuais antes do backup (poupando Assets.zip)
    find . -maxdepth 1 -name "*.zip" ! -name "Assets.zip" -delete

    git add .
    if ! git diff-index --quiet HEAD --; then
        echo "[Launcher] Mudanças detectadas. Criando commit..."
        git commit -m "Hytale Auto-save: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "[Launcher] Fazendo Push para o GitHub..."
        git push origin main
    else
        echo "[Launcher] Nada novo para salvar no mundo."
    fi
    
    echo "[Launcher] Concluído."
    break
done
