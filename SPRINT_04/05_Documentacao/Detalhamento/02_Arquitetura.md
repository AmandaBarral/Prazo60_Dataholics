# 02 · Arquitetura

## Visão geral

```text
                        ┌──────────────────────────────────────────────┐
  Navegador ──HTTPS────►│  Render · Web Service "prazo60" (FastAPI)    │
  (HTML/CSS/JS,         │  • /login, /app/* (só com sessão)            │
   Chart.js, SVG)       │  • /api/painel, /api/localizador,            │
                        │    /api/simulacao  ← base local minimizada   │
                        │  • /api/ia/perguntar ─────────────┐          │
                        └───────────────────────────────────┼──────────┘
                                                            │ mTLS (wallet)
                                                            ▼
                        ┌──────────────────────────────────────────────┐
                        │ Oracle Autonomous AI Database · Prazo60DB    │
                        │ usuário PRAZO60_APP (somente leitura)        │
                        │ 8 views agregadas VW_P60_*                   │
                        │ DBMS_CLOUD_AI · perfil PRAZO60_AI_GOOGLE ────┼──► Google Gemini
                        └──────────────────────────────────────────────┘      (gera o SQL)
  Power BI Service ◄── iframe (reportEmbed) na página Power BI
```

Duas fontes de dados convivem de propósito:

| Uso | Fonte | Motivo |
|---|---|---|
| Painéis, mapa, localizador, simulador | Base local minimizada `server/data/casos.csv.gz` (45.416 casos sem identificação) | Respostas em ~0,1 s, sem depender do banco; mesmos números do Oracle |
| Prazo60 AI (linguagem natural) | Oracle, views `VW_P60_*` | O Select AI precisa do banco para gerar e executar SQL |

## Componentes do servidor (`server/`)

| Arquivo | Responsabilidade |
|---|---|
| `main.py` | Rotas, cabeçalhos de segurança (CSP, HSTS…), sessão, proteção CSRF, limites de tentativa |
| `settings.py` | Configuração por variáveis de ambiente; normaliza o link do Power BI |
| `auth.py` | Hash PBKDF2-SHA256 (600.000 iterações) e limitador de tentativas |
| `analytics.py` | Motor analítico: filtros, KPIs, faixas, DRS, municípios, unidades, fluxos, alertas, recomendações, localizador |
| `simulation.py` | Simulador de encaminhamento (modelo de fila com premissas explícitas) |
| `select_ai.py` | Integração Select AI: contexto, geração de SQL, validação de leitura, execução, novas tentativas |
| `oracle/database.py` | Pool `python-oracledb` (modo thin, wallet) |
| `data/` | `casos.csv.gz` e `referencia.json` gerados pelo ETL |

## Frontend (`web/`)

| Pasta | Conteúdo |
|---|---|
| `web/public/` | Tela de login e logo (única parte acessível sem sessão) |
| `web/app/index.html` | Estrutura das 12 páginas, filtros globais, modal, modo apresentação |
| `web/app/css/` | `global.css` (tokens e componentes), `dashboard.css` (páginas), `responsive.css` |
| `web/app/js/core.js` | Utilitários, cliente da API, estado dos filtros, componentes, central de indicadores |
| `web/app/js/charts.js`, `map.js` | Gráficos (Chart.js), sankey e mapa em SVG |
| `web/app/js/views/*.js` | Uma view por página |
| `web/app/js/app.js` | Inicialização, roteamento por hash, filtros, modo apresentação |

## Fluxos principais

**Login:** `POST /api/auth/login` (JSON + cabeçalho `X-Requested-With`) → verificação PBKDF2 em tempo constante →
cookie de sessão assinado `prazo60_sessao` (HttpOnly, SameSite=Lax, Secure em produção, 8 h).

**Painel:** a página chama `GET /api/painel?ano=&mes=&drs=&municipio=&cnes=&tipo=&situacao=&dimensao=` → `BaseLocal.painel()`
calcula todos os agregados do recorte (com cache) → a view desenha KPIs, gráficos, tabelas e recomendações.

**Pergunta à IA:** `POST /api/ia/perguntar` → servidor monta contexto + pergunta → `DBMS_CLOUD_AI.GENERATE(action=>'showsql')`
→ extrai uma única consulta `SELECT/WITH` → executa como `PRAZO60_APP` (máx. 50 linhas, 45 s) → devolve colunas,
linhas e SQL. Se o modelo não devolver SQL ou o SQL falhar, tenta de novo informando o motivo (até 3 vezes).

## Estrutura do repositório

```text
prazo60-plataforma/
├── server/            API, autenticação, análises, simulação, Select AI, Oracle
├── web/public|app/    login e aplicação
├── etl/               build_data.py, fontes/, relatorio_validacao.md
├── scripts/           gerar_hash_senha.py, testar_select_ai.py, atualizar_perfil_views.py, SQL
├── tests/             test_plataforma.py (35 testes)
├── docs/              REQUISITOS.md, DEPLOY_RENDER.md, INTEGRACOES.md
├── render.yaml        Blueprint do Render
└── requirements.txt   fastapi, uvicorn, itsdangerous, python-dotenv, oracledb
```

Tamanho aproximado do código versionado: 15 arquivos Python (~2.100 linhas), 17 arquivos JavaScript (~1.700 linhas),
4 CSS (~640 linhas), 2 HTML (~650 linhas).
