#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
bash -n scripts/provisionar.sh scripts/verificar.sh
bash scripts/provisionar.sh --dry-run > /tmp/iac-dio-dryrun-$$.txt
trap 'rm -f /tmp/iac-dio-dryrun-$$.txt' EXIT
grep -q 'groupadd GRP_ADM' /tmp/iac-dio-dryrun-$$.txt
grep -q 'chmod 2770' /tmp/iac-dio-dryrun-$$.txt
grep -q 'chmod 1777' /tmp/iac-dio-dryrun-$$.txt
echo 'Testes de sintaxe e simulacao: OK'
