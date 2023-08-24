#!/bin/bash

# Função para exibir mensagens de erro e sair
error_exit() {
    echo "Erro: $1" >&2
    exit 1
}

# Verificar se o script está sendo executado como root
if [[ $EUID -ne 0 ]]; then
   error_exit "Este script deve ser executado como root."
fi

# Verificar e instalar pacotes necessários
if ! command -v apache2 &>/dev/null; then
    apt-get update || error_exit "Falha ao atualizar repositórios."
    apt-get install apache2 wget unzip -y || error_exit "Falha ao instalar pacotes."
fi

# Iniciar e habilitar o serviço Apache2
systemctl is-active --quiet apache2 || systemctl start apache2 || error_exit "Falha ao iniciar o Apache2."
systemctl is-enabled --quiet apache2 || systemctl enable apache2 || error_exit "Falha ao habilitar o Apache2."

# Diretório temporário
tmp_dir=$(mktemp -d)

# Baixar e extrair o arquivo ZIP
wget -q https://github.com/denilsonbonatti/linux-site-dio/archive/refs/heads/main.zip -P "$tmp_dir" || error_exit "Falha ao baixar o arquivo ZIP."
unzip -q "$tmp_dir/main.zip" -d "$tmp_dir" || error_exit "Falha ao extrair o arquivo ZIP."

# Copiar conteúdo para o diretório do servidor web
cp -r "$tmp_dir/linux-site-dio-main/"* /var/www/html/ || error_exit "Falha ao copiar para o diretório do servidor web."

# Reiniciar o serviço Apache2
systemctl restart apache2 || error_exit "Falha ao reiniciar o Apache2."

# Limpar o diretório temporário
rm -r "$tmp_dir"

echo "Configuração e instalação concluídas com sucesso!"
