# Roteiro de execução e evidências

1. Crie uma **VM descartável** Ubuntu e faça snapshot antes de alterar contas locais.
2. Extraia o projeto e abra o terminal na pasta do repositório.
3. Rode `bash tests/teste_estatico.sh` e confira o resultado `OK`.
4. Rode `bash scripts/provisionar.sh --dry-run` para revisar o plano.
5. Inspecione contas existentes: `getent passwd ana` e `getent group GRP_ADM`.
6. Execute `sudo bash scripts/provisionar.sh`.
7. Confira `sudo bash scripts/verificar.sh`.
8. Execute novamente o script para verificar que não duplica as contas.
9. Registre capturas de tela ou saídas textuais **sem senhas** em um arquivo de suas próprias evidências.
10. Faça um commit com sua documentação e publique no GitHub.

## Comandos para inspeção

```bash
getent group GRP_ADM GRP_VEN GRP_SEC
id ana
id daniel
id gabriela
stat -c '%a %U:%G %n' /srv/iac-dio/{adm,ven,sec,publico}
```

## Resultado esperado

Os grupos devem existir, os nove usuários devem pertencer aos seus respectivos grupos e os diretórios devem exibir permissões `2770` (departamentos) e `1777` (público).

> Importante: não execute em servidores de produção; as contas criadas são reais e não são removidas pelo script.
