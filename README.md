# Infraestrutura como Código: usuários, grupos e permissões no Linux

Projeto prático para o desafio **Infraestrutura como Código (IaC)** da [DIO](https://www.dio.me/). Um script Bash automatiza a configuração inicial de usuários, grupos e diretórios de uma máquina virtual Linux, com ênfase em repetibilidade e permissões seguras.

## O que o projeto faz

- Cria três grupos: `GRP_ADM`, `GRP_VEN` e `GRP_SEC`.
- Cria nove usuários de exemplo e associa cada um ao seu grupo.
- Cria os diretórios `adm`, `ven`, `sec` e `publico` sob `/srv/iac-dio` (configurável).
- Aplica permissões `2770` aos diretórios departamentais (com *setgid*) e `1777` ao diretório público (com *sticky bit*).
- Aceita `--dry-run` para mostrar o que seria feito, sem modificar a máquina.
- Pode ser executado novamente: verifica grupos e usuários antes de criá-los e preserva outras associações de grupo.
- Não atribui senhas fixas nem ativa login SSH.

## Estrutura

```text
linux-iac-usuarios-grupos/
├── scripts/
│   ├── provisionar.sh     # Executa a configuração
│   └── verificar.sh       # Exibe usuarios, grupos e permissoes
├── tests/
│   └── teste_estatico.sh  # Valida a sintaxe e a simulacao
├── docs/
│   ├── roteiro.md         # Execucao e validacao passo a passo
│   └── entrega-dio.md    # Texto sugerido para entrega
├── .github/workflows/
│   └── validate.yml      # Testes basicos no GitHub Actions
├── .gitignore
└── README.md
```

## Planejamento da infraestrutura

| Grupo | Usuários de exemplo | Diretório | Permissão |
|---|---|---|---|
| GRP_ADM | ana, bruno, carla | `/srv/iac-dio/adm` | `2770` |
| GRP_VEN | daniel, elisa, fabio | `/srv/iac-dio/ven` | `2770` |
| GRP_SEC | gabriela, henrique, isabela | `/srv/iac-dio/sec` | `2770` |
| Público | Todos (sujeito ao sistema) | `/srv/iac-dio/publico` | `1777` |

> `2770` permite acesso ao dono e ao grupo, bloqueando outros usuários. O bit `2` (*setgid*) mantém a herança do grupo. `1777` permite escrita geral, mas o bit `1` (*sticky*) evita que usuários comuns removam arquivos de outros proprietários.

## Requisitos

- Máquina virtual de teste com Ubuntu/Debian ou outra distribuição Linux com `bash`, `getent`, `useradd`, `usermod`, `groupadd`, `chmod`, `chown` e `stat`.
- Permissão `sudo` para aplicar alterações.
- Git para publicação.

## Executar em uma VM de laboratório

```bash
bash tests/teste_estatico.sh
bash scripts/provisionar.sh --dry-run
sudo bash scripts/provisionar.sh
sudo bash scripts/verificar.sh
```

Opcional: alterar diretório base de destino:

```bash
sudo bash scripts/provisionar.sh --base-dir /opt/laboratorio-iac
sudo bash scripts/verificar.sh /opt/laboratorio-iac
```

Para reproduzir uma estrutura diretamente na raiz, como `/adm` e `/publico`, seria necessário usar `--base-dir /`, opção **intencionalmente bloqueada** no script para evitar alterações acidentais. Prefira ambientes isolados e o padrão `/srv/iac-dio`.

## Segurança e limites

- **Execute apenas em VM de laboratório**: o script cria contas reais, grupos e diretórios no sistema.
- Os nomes de usuários são exemplos. Confira se já existem contas com esses nomes antes de executar.
- Senhas não são criadas pelo script. Se precisar habilitar login local, defina individualmente com `sudo passwd ana` e siga a política de senhas do ambiente.
- O script não apaga usuários, não remove grupos, não formata discos e não altera `sudoers`.
- Evite usar `chmod 777` nos diretórios departamentais.
- Reexecutar é seguro para os objetos previstos, mas não substitui ferramentas avançadas de gestão de configuração para ambiente de produção.

## Como publicar

Crie um repositório público vazio no GitHub chamado `linux-iac-usuarios-grupos` e, dentro da pasta do projeto, execute:

```bash
git init
git add .
git commit -m "feat: automatiza usuarios grupos e permissoes no Linux"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/linux-iac-usuarios-grupos.git
git push -u origin main
```

Se já existir `origin`, use `git remote -v` e, **somente se necessário**, `git remote set-url origin URL_CORRETA`.

## Créditos

Projeto autoral de aprendizagem desenvolvido a partir da proposta do desafio da DIO. Adapte os usuários, comente decisões e registre seus próprios testes antes de entregar.
