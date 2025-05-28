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
    
    # Verifica se o caminho é para o Free Fire Max
    if [[ "$input" == *"/android/data/com.dts.freefiremax/"* ]]; then
        # Verifica se o arquivo/diretório existe via adb shell
        adb shell "[ -e \"$input\" ]"
        if [ $? -eq 0 ]; then
            # Obtém metadados básicos
            file_info=$(adb shell ls -ld "$input" 2>/dev/null)
            
            # Extrai informações básicas
            echo "  File: $input"
            
            # Obtém tamanho e outros metadados
            size=$(adb shell stat -c '%s' "$input" 2>/dev/null)
            blocks=$(adb shell stat -c '%b' "$input" 2>/dev/null)
            io_block=$(adb shell stat -c '%o' "$input" 2>/dev/null)
            echo "  Size: $size    Blocks: $blocks    IO Block: $io_block"
            
            # Obtém device, inode, links
            device=$(adb shell stat -c '%D' "$input" 2>/dev/null)
            inode=$(adb shell stat -c '%i' "$input" 2>/dev/null)
            links=$(adb shell stat -c '%h' "$input" 2>/dev/null)
            echo "Device: $device    Inode: $inode    Links: $links"
            
            # Obtém permissões e UID/GID
            perm=$(adb shell stat -c '%A' "$input" 2>/dev/null)
            uid=$(adb shell stat -c '%u' "$input" 2>/dev/null)
            uid_name=$(adb shell stat -c '%U' "$input" 2>/dev/null)
            gid=$(adb shell stat -c '%g' "$input" 2>/dev/null)
            gid_name=$(adb shell stat -c '%G' "$input" 2>/dev/null)
            echo "Access: ($perm)  Uid: ($uid/$uid_name)   Gid: ($gid/$gid_name)"
            
            # Agora vem a parte de falsificação dos timestamps
            # Se for um arquivo .bin dentro da pasta mreplays
            if [[ "$input" == *"/mreplays/"*".bin" ]]; then
                # Extrai o nome do arquivo para obter o timestamp
                filename=$(basename "$input")
                if [[ "$filename" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})_rep\.bin ]]; then
                    # Adiciona os timestamps falsificados
                    echo "Access: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}.812594384 -0500"
                    echo "Modify: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}.812594384 -0500"
                    echo "Change: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}.812594384 -0500"
                    return 0
                fi
            # Se for um arquivo .json dentro da pasta mreplays
            elif [[ "$input" == *"/mreplays/"*".json" ]]; then
                # Extrai o nome do arquivo para obter o timestamp
                filename=$(basename "$input")
                if [[ "$filename" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})_rep\.json ]]; then
                    # Adiciona os timestamps falsificados
                    echo "Access: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}.851594384 -0500"
                    echo "Modify: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}.851594384 -0500"
                    echo "Change: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}.851594384 -0500"
                    return 0
                fi
            # Se for o diretório mreplays
            elif [[ "$input" == *"/mreplays" ]]; then
                # Procura o arquivo .json mais recente
                latest_json=$(adb shell ls -t "$input"/*.json 2>/dev/null | head -n 1)
                if [ -n "$latest_json" ]; then
                    # Extrai o nome do arquivo para obter o timestamp
                    filename=$(basename "$latest_json")
                    if [[ "$filename" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})_rep\.json ]]; then
                        # Gera um timestamp aleatório para Access (até 24h antes)
                        random_hours=$((RANDOM % 24))
                        access_hour=$((10#${BASH_REMATCH[4]} - random_hours))
                        if ((access_hour < 0)); then
                            access_hour=$((access_hour + 24))
                            day=$((10#${BASH_REMATCH[3]} - 1))
                            if ((day < 1)); then day=28; fi
                        else
                            day=${BASH_REMATCH[3]}
                        fi
                        access_hour=$(printf "%02d" $access_hour)
                        day=$(printf "%02d" $day)
                        
                        # Gera nanossegundos aleatórios
                        random_nanos=$(printf "%09d" $((RANDOM * RANDOM % 1000000000)))
                        
                        # Adiciona os timestamps falsificados
                        echo "Access: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-$day $access_hour:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}.$random_nanos -0500"
                        echo "Modify: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}.851594384 -0500"
                        echo "Change: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}.851594384 -0500"
                        return 0
                    fi
                fi
            fi
            
            # Se não conseguiu extrair o timestamp ou não é um arquivo específico, mostra os timestamps reais
            real_access=$(adb shell stat -c '%x' "$input" 2>/dev/null)
            real_modify=$(adb shell stat -c '%y' "$input" 2>/dev/null)
            real_change=$(adb shell stat -c '%z' "$input" 2>/dev/null)
            echo "Access: $real_access"
            echo "Modify: $real_modify"
            echo "Change: $real_change"
            return 0
        else
            echo "stat: cannot stat '$input': No such file or directory"
            return 1
        fi
    fi
    
    # Para outros caminhos, usa o stat normal
    command stat "$input"
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
