# 01 · Visão geral e links

## O problema

A **Lei nº 12.732/2012** garante ao paciente com câncer o início do primeiro tratamento no SUS em até **60 dias**
contados do diagnóstico. Nos 45.416 casos de câncer de mama (CID-10 C50) de mulheres analisados no Estado de
São Paulo (diagnósticos de 2022 a abril de 2026), **61,3% iniciaram o tratamento após o prazo legal**, com mediana de **79 dias**.

## A pergunta que a plataforma responde

1. **O que está acontecendo?** As pacientes iniciam o tratamento em 60 dias? (diagnóstico)
2. **Onde está acontecendo?** Em quais regiões (DRS), municípios e unidades? (localização)
3. **O que podemos fazer?** Quais alternativas existem nos dados e qual o impacto estimado? (apoio à decisão)

A plataforma segue a cadeia **dados → informação → diagnóstico → gargalo → alternativa → simulação → decisão**
e identifica em toda tela o que é **dado real**, **estimativa**, **simulação**, **projeção** ou **demonstração**.

## Equipe

Grupo **Dataholics**: Amanda, Eduardo, Gabriela, Julia e Livia.

| Instituição | Trabalho | Banca avaliadora |
|---|---|---|
| FIAP | CHALLENGE | Oracle |

## Links e ambientes

| Ambiente | Endereço / identificação |
|---|---|
| Site em produção | https://prazo60.onrender.com (login `DATAHOLICS` / `PRAZO60`) |
| Código-fonte (repositório unificado) | https://github.com/bambulimeduardo-design/prazo60-plataforma (branch `main`; entregas das Sprints 1 a 4 em `entregas/`) |
| Hospedagem | Render · workspace Dataholics · serviço `prazo60` (plano Free, região Virginia) |
| Banco de dados | Oracle Autonomous AI Database `Prazo60DB` · 26ai · Always Free · Lakehouse · `sa-saopaulo-1` |
| Identificador do banco (PDB) | `GC9981D36774D5D_PRAZO60DB` |
| Modelo de linguagem | Google Gemini `gemini-flash-lite-latest` via Oracle Select AI (perfil `PRAZO60_AI_GOOGLE`) |
| Power BI | Relatório no workspace pessoal, incorporado via `reportEmbed` |

## Versões publicadas (Git)

| Commit | Data | Conteúdo |
|---|---|---|
| `98dd1ee` | 13/09/2026 18:58 | Plataforma completa: login, análises, localizador, simulador e Select AI |
| `1bb22f1` | 13/09/2026 19:25 | Select AI aceita SQL em bloco de código, nova tentativa e perguntas de exemplo |
| `fa9556b` | 13/09/2026 19:47 | Camada analítica `VW_P60_*` e orientação do modelo por tipo de pergunta |

## Tecnologias

| Camada | Tecnologia | Função |
|---|---|---|
| Dados | Painel-Oncologia (INCA/DATASUS), CNES, CIB-SP, IBGE | Fontes públicas |
| ETL | Python (`etl/build_data.py`) | Limpeza, minimização, validação |
| Banco | Oracle Autonomous AI Database | Base completa, views analíticas, Select AI |
| IA | Oracle Select AI (`DBMS_CLOUD_AI`) + Google Gemini | Perguntas em linguagem natural → SQL |
| API | FastAPI + Uvicorn (Python 3.12) | Autenticação, agregados, simulação, IA |
| Frontend | HTML5, CSS3, JavaScript modular, Chart.js 4.5.1, SVG | 12 páginas, filtros, mapa, gráficos |
| BI | Power BI | Análise complementar incorporada |
| Deploy | GitHub + Render (Blueprint `render.yaml`) | Publicação contínua com HTTPS |
| Testes | pytest (35 testes) | Segurança, números, fluxos |
