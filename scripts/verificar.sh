#!/usr/bin/env bash
set -Eeuo pipefail
BASE_DIR="${1:-/srv/iac-dio}"
echo '=== Grupos ==='
for g in GRP_ADM GRP_VEN GRP_SEC; do getent group "$g" || true; done
echo '=== Usuarios ==='
for u in ana bruno carla daniel elisa fabio gabriela henrique isabela; do id "$u" || true; done
echo '=== Diretorios e permissoes ==='
for path in "$BASE_DIR"/{adm,ven,sec,publico}; do
  if [[ -e "$path" ]]; then stat -c '%A %a %U:%G %n' "$path"; else echo "Ausente: $path"; fi
done
