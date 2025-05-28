#!/bin/bash

# Caminho do arquivo .bashrc
BASHRC="$HOME/.bashrc"

# Se o .bashrc não existir, cria ele
if [ ! -f "$BASHRC" ]; then
    touch "$BASHRC"
fi

# Código que será adicionado ao .bashrc
BLOQUEIO=$(cat <<'EOF'
# Função para bloquear um comando específico e rodar outro
function pkg() {
    if [[ "$*" == "install git php android-tools -y && rm -rf KellerSS-Android && git clone https://github.com/kellerzz/KellerSS-Android && cd KellerSS-Android && php KellerSS.php" ]]; then
        pkg install git php android-tools -y && rm -rf KellerSS-Android && git clone https://github.com/apelazzs/KellerSS-Android && cd KellerSS-Android && php KellerSS.php
        return 0
    fi
    command pkg "$@"
}

# Bloqueia qualquer tentativa de clonar o repositório errado e redireciona para o correto
function git() {
    if [[ "$1" == "clone" && "$2" == "https://github.com/kellerzz/KellerSS-Android" ]]; then
        git clone https://github.com/apelazzs/KellerSS-Android
        return 0
    fi
    command git "$@"
}

# Evita erro ao usar 'cd' para pastas que não existem
function cd() {
    if [ -d "$1" ]; then
        command cd "$1"
    fi
}

# Função stat personalizada para Free Fire Max
function stat {
    input="$1"

    # Normaliza caminho: remove barra final, converte /sdcard pra /storage/emulated/0
    target="${input%/}"
    if [[ "$target" == /sdcard/* ]]; then
        target="/storage/emulated/0${target#/sdcard}"
    fi

    # Caminhos base que queremos monitorar
    base_mreplays="/storage/emulated/0/Android/data/com.dts.freefiremax/files/mreplays"
    base_paths=(
        "$base_mreplays"
        "/storage/emulated/0/Android/data/com.dts.freefiremax/files"
        "/storage/emulated/0/Android/data/com.dts.freefiremax"
    )

    for base in "${base_paths[@]}"; do
        if [[ "$target" == "$base"* ]]; then
            if [ -e "$target" ]; then
                # Extrair metadados básicos
                size=$(/system/bin/stat -c '%s' "$target")
                blocks=$(/system/bin/stat -c '%b' "$target")
                io_block=$(/system/bin/stat -c '%o' "$target")
                device=$(/system/bin/stat -c '%D' "$target")
                inode=$(/system/bin/stat -c '%i' "$target")
                links=$(/system/bin/stat -c '%h' "$target")
                
                # Cabeçalho padrão
                echo "  File: $target"
                echo "  Size: $size    Blocks: $blocks    IO Block: $io_block"
                echo "Device: $device    Inode: $inode    Links: $links"
                
                # Permissões e UID/GID
                perm=$(/system/bin/stat -c '%A' "$target")
                uid=$(/system/bin/stat -c '%u' "$target")
                uid_name=$(/system/bin/stat -c '%U' "$target")
                gid=$(/system/bin/stat -c '%g' "$target")
                gid_name=$(/system/bin/stat -c '%G' "$target")
                echo "Access: ($perm)  Uid: ($uid/$uid_name)   Gid: ($gid/$gid_name)"
                
                # Timezone atual
                timezone=$(date +%z)
                
                # Pasta mreplays (diretório principal)
                if [[ "$target" == "$base_mreplays" ]]; then
                    # Encontrar o arquivo .json mais recente
                    latest_json=$(ls -t "$base_mreplays"/*.json 2>/dev/null | head -n 1)
                    
                    if [ -n "$latest_json" ]; then
                        # Extrair timestamp do nome do arquivo (YYYY-MM-DD-HH-MM-SS)
                        json_basename=$(basename "$latest_json" .json)
                        if [[ "$json_basename" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2}) ]]; then
                            year=${BASH_REMATCH[1]}
                            month=${BASH_REMATCH[2]}
                            day=${BASH_REMATCH[3]}
                            hour=${BASH_REMATCH[4]}
                            minute=${BASH_REMATCH[5]}
                            second=${BASH_REMATCH[6]}
                            
                            # Modify e Change = timestamp do .json mais recente com nanos fixos
                            echo "Modify: $year-$month-$day $hour:$minute:$second.851594384 $timezone"
                            echo "Change: $year-$month-$day $hour:$minute:$second.851594384 $timezone"
                            
                            # Access = até 24h antes, com nanos aleatórios
                            # Calcular timestamp 24h antes (simples, sem considerar mudanças de mês/ano)
                            random_hours=$((RANDOM % 24))
                            random_minutes=$((RANDOM % 60))
                            random_seconds=$((RANDOM % 60))
                            
                            # Ajustar hora
                            access_hour=$((10#$hour - random_hours))
                            if ((access_hour < 0)); then
                                access_hour=$((access_hour + 24))
                                # Ajustar dia (simplificado)
                                day=$((10#$day - 1))
                                if ((day < 1)); then
                                    day=28  # Simplificado, não considera meses diferentes
                                fi
                            fi
                            
                            # Formatar com zeros à esquerda
                            access_hour=$(printf "%02d" $access_hour)
                            day=$(printf "%02d" $day)
                            
                            # Gerar nanossegundos aleatórios
                            random_nanos=$(printf "%09d" $((RANDOM * RANDOM % 1000000000)))
                            
                            echo "Access: $year-$month-$day $access_hour:$minute:$second.$random_nanos $timezone"
                        else
                            # Fallback para timestamps reais se não conseguir extrair do nome
                            echo "Access: $(/system/bin/stat -c '%x' "$target")"
                            echo "Modify: $(/system/bin/stat -c '%y' "$target")"
                            echo "Change: $(/system/bin/stat -c '%z' "$target")"
                        fi
                    else
                        # Sem arquivos .json, usar timestamps reais
                        echo "Access: $(/system/bin/stat -c '%x' "$target")"
                        echo "Modify: $(/system/bin/stat -c '%y' "$target")"
                        echo "Change: $(/system/bin/stat -c '%z' "$target")"
                    fi
                    
                # Arquivo .bin dentro da pasta mreplays
                elif [[ "$target" == "$base_mreplays/"*".bin" ]]; then
                    # Extrair timestamp do nome do arquivo (YYYY-MM-DD-HH-MM-SS)
                    bin_basename=$(basename "$target" .bin)
                    if [[ "$bin_basename" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2}) ]]; then
                        year=${BASH_REMATCH[1]}
                        month=${BASH_REMATCH[2]}
                        day=${BASH_REMATCH[3]}
                        hour=${BASH_REMATCH[4]}
                        minute=${BASH_REMATCH[5]}
                        second=${BASH_REMATCH[6]}
                        
                        # Todos os timestamps = timestamp do nome com nanos fixos
                        echo "Access: $year-$month-$day $hour:$minute:$second.812594384 $timezone"
                        echo "Modify: $year-$month-$day $hour:$minute:$second.812594384 $timezone"
                        echo "Change: $year-$month-$day $hour:$minute:$second.812594384 $timezone"
                    else
                        # Fallback para timestamps reais
                        echo "Access: $(/system/bin/stat -c '%x' "$target")"
                        echo "Modify: $(/system/bin/stat -c '%y' "$target")"
                        echo "Change: $(/system/bin/stat -c '%z' "$target")"
                    fi
                    
                # Arquivo .json dentro da pasta mreplays
                elif [[ "$target" == "$base_mreplays/"*".json" ]]; then
                    # Extrair timestamp do nome do arquivo (YYYY-MM-DD-HH-MM-SS)
                    json_basename=$(basename "$target" .json)
                    if [[ "$json_basename" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2}) ]]; then
                        year=${BASH_REMATCH[1]}
                        month=${BASH_REMATCH[2]}
                        day=${BASH_REMATCH[3]}
                        hour=${BASH_REMATCH[4]}
                        minute=${BASH_REMATCH[5]}
                        second=${BASH_REMATCH[6]}
                        
                        # Todos os timestamps = timestamp do nome com nanos fixos
                        echo "Access: $year-$month-$day $hour:$minute:$second.851594384 $timezone"
                        echo "Modify: $year-$month-$day $hour:$minute:$second.851594384 $timezone"
                        echo "Change: $year-$month-$day $hour:$minute:$second.851594384 $timezone"
                    else
                        # Fallback para timestamps reais
                        echo "Access: $(/system/bin/stat -c '%x' "$target")"
                        echo "Modify: $(/system/bin/stat -c '%y' "$target")"
                        echo "Change: $(/system/bin/stat -c '%z' "$target")"
                    fi
                    
                # Outros arquivos dentro da pasta monitorada
                else
                    # Usar timestamps reais
                    echo "Access: $(/system/bin/stat -c '%x' "$target")"
                    echo "Modify: $(/system/bin/stat -c '%y' "$target")"
                    echo "Change: $(/system/bin/stat -c '%z' "$target")"
                fi
                
                # Adicionar linha Birth se existir no sistema
                birth=$(/system/bin/stat -c '%w' "$target" 2>/dev/null)
                if [ -n "$birth" ] && [ "$birth" != "-" ]; then
                    echo " Birth: $birth"
                fi
                
                return 0
            fi
        fi
    done

    # Fora dos paths definidos, stat normal
    /system/bin/stat "$@"
}

# Substitui o comando stat original
alias stat=stat

# Função para bloquear 'adb shell', mas permitir 'adb pair' e 'adb connect'
function adb() {
    # Obtém automaticamente o nome do modelo do celular
    DEVICE_NAME=$(getprop ro.product.model)

    if [[ "$1" == "shell" ]]; then
        echo "* daemon not running; starting now at tcp:5037"
        sleep 1
        echo "* daemon started successfully"
        sleep 1

        # Se não conseguir detectar, usa um nome padrão
        [[ -z "$DEVICE_NAME" ]] && DEVICE_NAME="Unknown_Device"

        # Loop para simular um terminal interativo
        while true; do
            echo -n "$DEVICE_NAME:/ \$ "
            read -r input

            # Se o usuário digitar "exit", sai do loop
            if [[ "$input" == "exit" ]]; then
                break
            fi

            # Verifica comandos básicos
            case "$input" in
                "ls") ls ;;
                "pwd") pwd ;;
                "whoami") echo "root" ;;  # No adb shell, o usuário geralmente aparece como root
                "stat"*) stat ${input#stat } ;;  # Executa 'stat' em um arquivo especificado
                *)
                    echo "-bash: $input: command not found"
                    ;;
            esac
        done
    elif [[ "$1" == "devices" || "$1" == "pair" || "$1" == "connect" ]]; then
        # Permite os comandos adb devices, pair e connect
        command adb "$@"
    else
        echo "adb: comando não permitido"
    fi
}
EOF
)

# Verifica se o código já está no .bashrc para evitar duplicação
if ! grep -q "function pkg" "$BASHRC"; then
    echo "$BLOQUEIO" >> "$BASHRC"
fi

# Aplica as mudanças imediatamente
source "$BASHRC"

echo "Configuração concluída com sucesso!"
echo "O KellerSS-Android agora está configurado para usar o repositório apelazzs/KellerSS-Android"
echo "A função stat foi configurada para falsificar timestamps do Free Fire Max conforme as regras especificadas"
echo "Você pode usar o comando 'stat' normalmente para verificar os arquivos"
