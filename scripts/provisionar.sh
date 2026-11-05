#!/usr/bin/env bash
# Laboratorio IaC: criacao idempotente de usuarios, grupos e diretorios.
set -Eeuo pipefail

BASE_DIR="/srv/iac-dio"
DRY_RUN=false

usage() {
  cat <<'USAGE'
Uso: sudo bash scripts/provisionar.sh [--dry-run] [--base-dir CAMINHO]
  --dry-run         Mostra o plano sem modificar o sistema
  --base-dir PATH   Diretório base absoluto (padrao: /srv/iac-dio)
  -h, --help        Exibe esta ajuda
USAGE
}

while (($#)); do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --base-dir) [[ $# -ge 2 ]] || { echo 'Falta caminho para --base-dir' >&2; exit 2; }; BASE_DIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opcao desconhecida: $1" >&2; usage; exit 2 ;;
  esac
done

[[ "$BASE_DIR" == /* && "$BASE_DIR" != / ]] || { echo 'Use caminho absoluto diferente de /' >&2; exit 2; }
[[ "$BASE_DIR" != *'/../'* && "$BASE_DIR" != */.. && "$BASE_DIR" != *'/./'* ]] || { echo 'Caminho base invalido' >&2; exit 2; }
if [[ "$DRY_RUN" != true && "$EUID" -ne 0 ]]; then
  echo 'Execute como root (sudo) ou utilize --dry-run' >&2
  exit 1
fi

log() { printf '[IaC] %s\n' "$*"; }
execute() {
  if [[ "$DRY_RUN" == true ]]; then
    printf '[SIMULACAO]'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

# Grupos e respectivos usuarios suplementares.
GROUPS_TO_CREATE=(GRP_ADM GRP_VEN GRP_SEC)
USER_GROUP=(
  'ana:GRP_ADM' 'bruno:GRP_ADM' 'carla:GRP_ADM'
  'daniel:GRP_VEN' 'elisa:GRP_VEN' 'fabio:GRP_VEN'
  'gabriela:GRP_SEC' 'henrique:GRP_SEC' 'isabela:GRP_SEC'
)

log 'Criando/verificando grupos'
for group in "${GROUPS_TO_CREATE[@]}"; do
  if getent group "$group" >/dev/null; then
    log "Grupo existente: $group"
  else
    execute groupadd "$group"
  fi
done

log 'Criando/verificando usuarios e associacoes'
for entry in "${USER_GROUP[@]}"; do
  user="${entry%%:*}"; group="${entry#*:}"
  if id "$user" >/dev/null 2>&1; then
    log "Usuario existente: $user (nao alterar senha, shell ou home)"
  else
    execute useradd -m -s /bin/bash "$user"
  fi
  # -aG preserva associacoes suplementares existentes.
  execute usermod -aG "$group" "$user"
done

log "Configurando diretorios em: $BASE_DIR"
execute mkdir -p -- "$BASE_DIR"
# Nao alterar permissao de um diretorio base preexistente, que pode ter outros usos.
for item in 'adm:GRP_ADM' 'ven:GRP_VEN' 'sec:GRP_SEC'; do
  folder="${item%%:*}"; group="${item#*:}"
  path="$BASE_DIR/$folder"
  execute mkdir -p -- "$path"
  execute chown root:"$group" -- "$path"
  execute chmod 2770 -- "$path"  # setgid: novos arquivos herdam o grupo
 done

# Compartilhamento de laboratorio: sticky bit impede exclusao de arquivos de terceiros.
execute mkdir -p -- "$BASE_DIR/publico"
execute chown root:root -- "$BASE_DIR/publico"
execute chmod 1777 -- "$BASE_DIR/publico"

log 'Concluido. Nenhuma senha foi definida automaticamente.'
log 'Defina senhas manualmente, apenas se necessarias, com: sudo passwd USUARIO'
