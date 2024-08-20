#!/bin/bash

# Caminho para o arquivo de configuração do multipath
CONFIG_FILE="/etc/multipath.conf"
TEMP_FILE="/etc/multipath.conf.tmp"

# Cria um backup do arquivo de configuração atual
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Cria um novo arquivo de configuração com a estrutura básica
cat <<EOF > "$TEMP_FILE"
multipaths {
EOF

# Função para adicionar novos dispositivos multipath
add_multipath() {
    while true; do
        read -p "Deseja adicionar um novo multipath? (s/n): " choice
        case "$choice" in
            [sS])
                read -p "Digite o WWID: " wwid
                read -p "Digite o Alias: " alias
                echo "    multipath {" >> "$TEMP_FILE"
                echo "        wwid \"$wwid\"" >> "$TEMP_FILE"
                echo "        alias \"$alias\"" >> "$TEMP_FILE"
                echo "    }" >> "$TEMP_FILE"
                ;;
            [nN])
                break
                ;;
            *)
                echo "Opção inválida. Digite 's' para sim ou 'n' para não."
                ;;
        esac
    done
}

# Adiciona novos dispositivos multipath
add_multipath

# Finaliza a estrutura no arquivo de configuração
echo "}" >> "$TEMP_FILE"

# Substitui o arquivo de configuração antigo pelo novo
mv "$TEMP_FILE" "$CONFIG_FILE"

# Reinicia o serviço multipathd para aplicar as mudanças
systemctl restart multipathd

# Força o reescaneamento dos dispositivos multipath
multipath -r

echo "Configuração de multipath atualizada com sucesso."
