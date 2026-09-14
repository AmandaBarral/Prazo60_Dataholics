# Prazo60 · Pasta de Documentação Final

> **Diagnóstico não pode esperar. Tratamento também não.**
> Plataforma de inteligência em saúde pública do grupo **Dataholics** para monitorar o cumprimento da
> **Lei nº 12.732/2012** (início do tratamento oncológico em até 60 dias) nos casos de câncer de mama no SUS do Estado de São Paulo.

| Instituição | Trabalho | Banca avaliadora |
|---|---|---|
| **FIAP** | **CHALLENGE** | **Oracle** |

Documentação consolidada em 13/09/2026.

---

## 1. Links

| O quê | Endereço | Observação |
|---|---|---|
| **Site (produção)** | https://prazo60.onrender.com | Hospedado no Render, HTTPS |
| **Repositório GitHub (unificado)** | https://github.com/bambulimeduardo-design/prazo60-plataforma | Branch `main` · plataforma na raiz e entregas das Sprints 1 a 4 em `entregas/` (commits da Amanda preservados) |
| **Vídeo do projeto (YouTube)** | https://youtu.be/S02jso3E94o | Citado na capa, na seção 1.4 e no Apêndice A do PDF |
| Repositório original da Amanda | https://github.com/AmandaBarral/Prazo60_Dataholics | Histórico das Sprints 1 a 3, incorporado ao unificado |
| **Render (painel)** | https://dashboard.render.com | Workspace **Dataholics** · Blueprint e Web Service **prazo60** |
| **Oracle Cloud (banco)** | https://cloud.oracle.com | Autonomous AI Database **Prazo60DB** · Brazil East (São Paulo) |
| **Google AI Studio** | https://aistudio.google.com | Chave de API usada pelo Select AI (provedor Gemini) |
| **Relatório Power BI** | https://app.powerbi.com/groups/me/reports/0a799b85-3b20-4162-81b6-d3a61ba73ff7/d1bb6caba29ffc924e85 | Incorporado na página *Power BI* do site |
| Roteiro Select AI (histórico) | https://claude.ai/code/artifact/f5e38549-e366-470c-90cb-f8865a02f638 | Versão com OCI Generative AI, substituída pelo Google Gemini |

## 2. Acesso ao site (avaliação)

| Usuário | Senha |
|---|---|
| `DATAHOLICS` | `PRAZO60` |

O usuário não diferencia maiúsculas/minúsculas; a senha diferencia. A senha fica no servidor apenas como hash PBKDF2.
Para trocá-la depois da avaliação, veja `02_Detalhamento/10_Operacao_e_Manutencao.md`.

No plano gratuito do Render o site “hiberna” após 15 min sem uso: o primeiro acesso pode levar ~50 s.

## 3. Conteúdo desta pasta

```text
Prazo60_Documentacao/
├── 00_LEIA-ME.md                      ← este índice
├── 01_Relatorio_TCC_Prazo60.pdf       ← relatório completo no formato de TCC
├── 02_Detalhamento/                   ← documentação técnica detalhada (12 documentos)
│   ├── 01_Visao_Geral_e_Links.md
│   ├── 02_Arquitetura.md
│   ├── 03_Dados_e_ETL.md
│   ├── 04_Banco_Oracle.md
│   ├── 05_Select_AI.md
│   ├── 06_Site_Plataforma.md
│   ├── 07_Seguranca_e_LGPD.md
│   ├── 08_Deploy_GitHub_Render.md
│   ├── 09_Testes_e_Validacao.md
│   ├── 10_Operacao_e_Manutencao.md
│   ├── 11_Historico_do_Projeto.md
│   └── 12_Limitacoes_e_Proximos_Passos.md
├── 03_Documentos_do_Repositorio/      ← cópias dos documentos versionados (requisitos, deploy, integrações…)
├── 04_Scripts_SQL/                    ← scripts Oracle na ordem de execução (sem chaves nem senhas)
├── 05_Evidencias/                     ← capturas de tela do sistema funcionando + índice
│   └── power_bi_e_sprint4/            ← 3 abas do Power BI, arquitetura Lambda e FTP do DATASUS
├── 06_Identidade_Visual/              ← logos em JPEG HD
├── 07_Entregas_Challenge/             ← relatório técnico da Sprint 4
└── _fonte/                            ← fontes para regenerar o PDF e as capturas
```

## 4. Onde está cada coisa no computador

| Item | Caminho |
|---|---|
| Código da plataforma (Git) | `C:\Projetos\prazo60-plataforma` |
| Scripts de carga Oracle (originais) | `C:\Projetos\Prazo60_Carga_Oracle\Prazo60_Carga_Oracle\Prazo60_Carga_Oracle` |
| Site anterior (versão estática) | `C:\Projetos\index.html`, `C:\Projetos\js`, `C:\Projetos\css` |
| Wallet Oracle extraído | `C:\Projetos\prazo60-plataforma\wallet` (fora do Git) |
| Variáveis locais (senhas Oracle) | `C:\Projetos\prazo60-plataforma\.env` (fora do Git) |

## 5. Segredos: onde ficam (e onde **nunca** ficam)

Nenhuma senha do banco, senha do wallet ou chave de API aparece nesta pasta, no GitHub ou no PDF.

| Segredo | Onde fica |
|---|---|
| Senha do `ADMIN` e do `PRAZO60_APP` | Com o grupo; `PRAZO60_APP` também no `.env` local e no Render (`ORACLE_PASSWORD`) |
| Senha do wallet | Com o grupo; `.env` local e Render (`ORACLE_WALLET_PASSWORD`) |
| Wallet (`tnsnames.ora`, `ewallet.pem`) | Pasta `wallet` local e Render › Secret Files |
| Chave do Google AI Studio | Somente dentro do banco, nas credenciais `GOOGLE_CRED` (ADMIN e PRAZO60_APP) |
| Segredo de sessão do site | Gerado pelo Render (`SESSION_SECRET`) |

> **Ação pendente de segurança:** o arquivo original `05_select_ai_google.sql` na pasta de carga foi salvo com uma chave
> do Google preenchida. Apague a chave desse arquivo e confirme no Google AI Studio que essa chave foi excluída.

## 6. Pendências conhecidas

1. Decidir se os 200 casos da Sprint 3 (`CASO-0001` a `CASO-0200`) permanecem no banco (hoje ficam fora das views da IA).
2. Nomes e endereços das unidades sem nome confirmado (94 de 114 CNES tratantes), via API CNES.
3. Trocar a senha do site após a apresentação, se o link for divulgado.
