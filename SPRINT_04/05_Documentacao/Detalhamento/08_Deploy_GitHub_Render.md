# 08 · Deploy: GitHub e Render

## GitHub

| Item | Valor |
|---|---|
| Repositório | https://github.com/bambulimeduardo-design/prazo60-plataforma |
| Visibilidade | **Privado** (contém a base minimizada de casos) |
| Branch | `main` |
| Conta | `bambulimeduardo-design` |
| Ignorados | `.env`, `wallet/`, `.claude/`, caches |

**Observação:** o Git do computador guardava o login de outra conta (`Bambulim05`). O remoto foi configurado com o
usuário na URL (`https://bambulimeduardo-design@github.com/...`), e o login foi feito pelo Git Credential Manager.

## Render

| Item | Valor |
|---|---|
| Workspace | Dataholics |
| Blueprint | `prazo60` (lê `render.yaml` da branch `main`) |
| Web Service | `prazo60` · Python 3.12.5 · plano Free · região Virginia |
| URL | https://prazo60.onrender.com |
| Build | `pip install -r requirements.txt` |
| Start | `uvicorn server.main:app --host 0.0.0.0 --port $PORT --proxy-headers --forwarded-allow-ips "*"` |
| Health check | `/api/saude` |
| Auto-deploy | Sim, a cada push na `main` |
| GitHub App | Render instalado só no repositório `prazo60-plataforma` |

### Variáveis de ambiente (nomes)

| Variável | Valor / origem |
|---|---|
| `PRAZO60_AMBIENTE` | `producao` |
| `SESSION_SECRET` | gerado pelo Render |
| `APP_USER` | `DATAHOLICS` |
| `SESSION_MAX_HOURS` | `8` |
| `POWERBI_EMBED_URL` / `POWERBI_TITULO` | link do relatório / título |
| `SELECT_AI_HABILITADO` | `true` |
| `SELECT_AI_PERFIL` / `SELECT_AI_PROVEDOR` | `PRAZO60_AI_GOOGLE` / `Google Gemini (gemini-flash-lite-latest)` |
| `ORACLE_USER` / `ORACLE_DSN` / `ORACLE_WALLET_DIR` | `PRAZO60_APP` / `prazo60db_low` / `/etc/secrets` |
| `ORACLE_PASSWORD` / `ORACLE_WALLET_PASSWORD` | informadas no painel (não versionadas) |

### Secret Files

`tnsnames.ora` e `ewallet.pem` (extraídos do `Wallet_Prazo60DB.zip`), disponíveis em `/etc/secrets`.

## Verificação em produção (13/09/2026)

- `GET https://prazo60.onrender.com/api/saude` → `200 {"status":"ok","casos_carregados":45416}`
- `GET /login` → 200 com `Content-Security-Policy` ativo
- Deploy `98dd1ee` “Deploy succeeded · Live” em 51,6 s; atualizações `1bb22f1` e `fa9556b` publicadas por auto-deploy.

## Como publicar uma alteração

```bash
cd C:\Projetos\prazo60-plataforma
python -m pytest -q
git add .
git commit -m "Descrição da alteração"
git push origin main
```

O Render refaz o deploy sozinho (~3 min). Acompanhe em **prazo60 › Events**.

## Plano gratuito

- Hiberna após 15 min sem acesso; primeiro acesso seguinte leva ~50 s. Abrir o site antes da apresentação.
- Para ficar sempre ligado: mudar o serviço para o plano *Starter* no painel.
