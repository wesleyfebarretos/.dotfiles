#!/bin/bash

# Caminho onde os repositórios estão localizados
BASE_PATH=""

# Configurações de usuário
USER_NAME=""
USER_EMAIL=""

# Função para configurar o usuário de commit
configure_git_user() {
  local repo_path="$1"
  if [ -d "$repo_path/.git" ]; then
    echo "Configurando usuário para $repo_path"
    cd "$repo_path"
    git config user.name "$USER_NAME"
    git config user.email "$USER_EMAIL"

    # Configura os submódulos, se houver
    if [ -f ".gitmodules" ]; then
      # git submodule update --init --recursive
      (
        export USER_NAME="$USER_NAME"
        export USER_EMAIL="$USER_EMAIL"
        git submodule foreach 'git config user.name "$USER_NAME"; git config user.email "$USER_EMAIL"'
      )
    fi
  else
    echo "Não é um repositório Git: $repo_path"
  fi
}

# Função para percorrer repositórios e submódulos
process_repositories() {
  local path="$1"
  find "$path" -type d -name ".git" | while read -r git_dir; do
    local repo_path="$(dirname "$git_dir")"
    configure_git_user "$repo_path"
  done
}

# Inicia o processamento a partir do caminho base
process_repositories "$BASE_PATH"
