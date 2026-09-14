# 04 · Banco Oracle (Prazo60DB)

## Identificação

| Item | Valor |
|---|---|
| Serviço | Oracle Autonomous AI Database 26ai · Always Free · workload Lakehouse |
| Região | Brazil East (São Paulo) · `sa-saopaulo-1` |
| PDB | `GC9981D36774D5D_PRAZO60DB` |
| Serviços de conexão | `prazo60db_high`, `_medium`, `_low`, `_tp`, `_tpurgent` (site usa `_low`) |
| Conexão | mTLS com wallet (`Wallet_Prazo60DB.zip`) · acesso “from everywhere” |
| Usuários | `ADMIN` (grupo) · `PRAZO60_APP` (site, somente leitura) |

## Modelo de dados (schema ADMIN)

| Tabela | Conteúdo |
|---|---|
| `TB_DRS` | 17 DRS + `DRS-00 Fora do Estado de SP` |
| `TB_MUNICIPIO` | 645 municípios de SP + sentinela (646) |
| `TB_UNIDADE_SAUDE` | 247 unidades (CNES) |
| `TB_TIPO_TRATAMENTO` | Quimioterapia, Radioterapia, Cirurgia, Quimioterapia + Radioterapia |
| `TB_STATUS_PRAZO` | Verde (≤30), Amarelo (31–45), Laranja (46–59), Vermelho (=60), Vencido (>60) |
| `TB_CASO_PACIENTE` | 45.616 casos (45.416 da carga + 200 da Sprint 3) |
| `TB_TRATAMENTO` | 45.616 tratamentos |
| `STG_CASOS_PRAZO60` | Staging com os 45.416 casos |
| `TB_OFERTA_DRS` | Oferta CACON/UNACON e mamografias por DRS e ano (2022–2026) |

## Ordem de execução dos scripts (`04_Scripts_SQL`)

| # | Script | Conexão | Resultado |
|---|---|---|---|
| 0 | `00_verificar_antes.sql` | ADMIN | Pré-requisitos (DRS, tipos, status) |
| 1 | `00_alterar_schema_residencia.sql` | ADMIN | Coluna de residência (já existia) |
| 2 | `01_criar_staging.sql` + `01b_…parte1..5.sql` | ADMIN | Staging com 45.416 linhas |
| 3 | `02a_popular_municipios.sql` / `02b_popular_unidades.sql` | ADMIN | 646 municípios · 247 unidades |
| 4 | `03_popular_fatos.sql` | ADMIN | 45.416 casos e tratamentos inseridos |
| 5 | `04_verificar_depois.sql` | ADMIN | Conferência com o site |
| 6 | `05_select_ai_google.sql` | ADMIN | Credencial e perfil Gemini do ADMIN |
| 7 | `06a_usuario_site_ADMIN.sql` | ADMIN | Usuário `PRAZO60_APP`, rede do Google |
| 8 | `06b_select_ai_site_APP.sql` | PRAZO60_APP | Credencial e perfil do site |
| 9 | `07_camada_analitica_select_ai.sql` | ADMIN | Views `VW_P60_*`, oferta, permissões |

Os arquivos `01b_carregar_staging_parte1..5.sql` (3,5 MB cada) e `staging_casos.csv` **não foram copiados** para esta
pasta: contêm dados em nível de caso (inclusive data de nascimento). Estão apenas na pasta de carga original.

## Correções aplicadas durante a carga (13/09/2026)

| Problema | Causa | Correção |
|---|---|---|
| `status = 0` na verificação | `TB_STATUS_PRAZO` usa códigos de cor, não `NO_PRAZO…` | `03_popular_fatos.sql` passou a usar Verde/Amarelo/Laranja/Vermelho/Vencido |
| ORA-00001 em `CASO-000344` | Município ID 5 “São José do Rio Preto” (Sprint 3) cadastrado com o IBGE 354990 (de São José dos Campos): 882 casos duplicados no JOIN e 644 residentes de Rio Preto iriam para “Fora do Estado” | `UPDATE TB_MUNICIPIO SET COD_IBGE='354980' WHERE ID_MUNICIPIO=5`; unidades `0009601` e `2748029` religadas ao município 579 (São José dos Campos) |
| ORA-01430 / ORA-02275 / ORA-00955 | Alteração de schema já feita antes | Nenhuma (inofensivo) |
| ORA-01031 ao rodar o `07` | Script executado na conexão `PRAZO60_APP` | Rodado como ADMIN; trava adicionada no início do script |

Também foram removidas 8 tabelas de exercício de outra disciplina (`TB_CLIENTES`, `TB_PEDIDOS`, `TB_PRODUTOS`,
`TB_ITENS_PEDIDOS`, `TB_GRUPOS_PRODUTOS`, `TB_MARCAS`, `TB_ENDERECOS`, `TB_VENDEDORES`), sem dependências do Prazo60.

**Conferência final (`04_verificar_depois.sql`):** 45.416 casos, 61,3% acima de 60 dias, mediana 79, nenhum caso
de fora, nenhum IBGE repetido e as 18 linhas por DRS idênticas ao site.

## Camada analítica para a IA (`07_camada_analitica_select_ai.sql`)

| View | Grão | Destaques |
|---|---|---|
| `VW_P60_BASE` | caso (interna, **não** liberada ao site) | Junta caso, tratamento, município, DRS, unidade e tipo |
| `VW_P60_RESUMO_ANO` | ano | `ANO_PARCIAL` |
| `VW_P60_RESUMO_MES` | ano e mês | `ANO_MES` (AAAA-MM) |
| `VW_P60_DRS_ANO` | DRS e ano | evolução |
| `VW_P60_DRS` | DRS | `PCT_ACIMA_60_2024/2025`, `VARIACAO_PP_2024_2025`, `ESTABELECIMENTOS_2025`, `PRESSAO_CASOS_POR_ESTABELECIMENTO` |
| `VW_P60_MUNICIPIO` | município (≥ 30 casos) | ranking |
| `VW_P60_UNIDADE` | unidade (≥ 30 casos) | ranking |
| `VW_P60_TIPO_TRATAMENTO` | tipo | média e mediana |
| `VW_P60_FAIXA_DIAS` | faixa de dias | distribuição |

Todas as views consideram só os casos com residência (os 45.416 da carga); os 200 da Sprint 3 ficam de fora.
Comentários em português (`COMMENT ON`) explicam cada view e coluna para o modelo de linguagem.

**Permissões do `PRAZO60_APP`:** `CREATE SESSION`, `EXECUTE` em `DBMS_CLOUD` e `DBMS_CLOUD_AI`, `SELECT` nas 8 views
agregadas. O acesso às tabelas de nível caso foi revogado.

**Conferência:** 45.416 casos e 27.830 acima de 60 dias; DRS XII - Registro com a maior piora (+10,4 p.p.).
