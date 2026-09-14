# Evidências · capturas de tela (13/09/2026)

A tela `00` foi capturada no endereço de produção (https://prazo60.onrender.com). As demais foram capturadas em
execução local da mesma versão do código (commit `fa9556b`), conectada ao mesmo banco Oracle, com Chrome em
1440×900 (e 390×844 para celular). Todas mostram dados reais.

| Arquivo | Página | O que comprova |
|---|---|---|
| `00_producao_login.png` | Login (produção) | Site publicado com HTTPS e tela de acesso |
| `01_login.png` | Login (local) | Mesma tela na execução local |
| `02_inicio.png` | Início | Evidência central: 61,3% acima de 60 dias, 45.416 casos |
| `03_visao_executiva.png` | Visão Executiva | 8 KPIs com variação, série mensal, distância até a meta |
| `03b_recomendacoes.png` | Visão Executiva | Cartões ATENÇÃO, RISCO, OPORTUNIDADE, AÇÃO SUGERIDA |
| `04_panorama_60_dias.png` | Panorama | Régua temporal, situação do prazo, faixas por ano |
| `05_demanda_oferta.png` | Demanda & Oferta | Pressão assistencial 108,6 casos/estab., dispersão e barras |
| `05b_fluxos_entre_regioes.png` | Demanda & Oferta | Sankey de fluxos residência → tratamento |
| `06_mapa.png` | Mapa | 17 DRS coloridas, municípios e unidades |
| `06b_mapa_drs_xiv.png` | Mapa | DRS XIV selecionada, detalhe e filtro aplicado |
| `07_gargalos.png` | Gargalos | 4 críticos, 1 atenção, 7 monitorar, 5 oportunidade; municípios críticos |
| `07b_fatores_relacionados.png` | Gargalos | Fatores por região com mediana estadual |
| `07c_motor_apoio_decisao.png` | Gargalos | Motor de apoio à decisão |
| `08_para_onde_encaminhar.png` | Localizador | Exemplo São Bernardo do Campo, onde tratam hoje |
| `08b_unidades_compativeis.png` | Localizador | Unidades com distância estimada, compatibilidade e CNES |
| `09_simulacao_etapa1.png` | Simulação | Etapa 1: município e fluxos reais |
| `09b_simulacao_etapa2.png` | Simulação | Etapa 2: cenários e premissas |
| `09c_simulacao_resultado.png` | Simulação | Cenário atual × simulado × impacto |
| `09d_simulacao_carga_unidades.png` | Simulação | Distribuição da demanda e carga por unidade |
| `10_power_bi.png` | Power BI | Relatório incorporado carregando |
| `11_prazo60_ai.png` | Inteligência Artificial | Pergunta ao Select AI, resultado do banco e SQL |
| `11b_prazo60_ai_ranking.png` | Inteligência Artificial | Ranking municipal com SQL |
| `12_dados_fontes.png` | Dados & Metodologia | Fontes |
| `12b_pipeline_arquitetura.png` | Dados & Metodologia | Pipeline e arquitetura tecnológica |
| `12c_qualidade_dados.png` | Dados & Metodologia | Qualidade dos dados |
| `12d_limitacoes.png` | Dados & Metodologia | Limitações |
| `13_sobre.png` | Sobre | Lei, problema, objetivo, equipe |
| `14_celular_visao_executiva.png` | Visão Executiva (celular) | Responsividade |

Para refazer as capturas: `_fonte/capturar_telas.py` (instruções no próprio arquivo).

## Power BI e Sprint 4 (`power_bi_e_sprint4/`)

Imagens extraídas do relatório técnico da Sprint 4 (`07_Entregas_Challenge/`). Os números foram conferidos com o
extrato tratado pelo pipeline (46.181 registros).

| Arquivo | O que mostra |
|---|---|
| `pbi_01_visao_executiva_tempo_espera.png` | 46.181 pacientes, 18.351 dentro do prazo (39,74%), tempo médio 109,94 dias, estadiamento, tratamentos |
| `pbi_02_pressao_regional_fluxo.png` | Mapa da demanda, top 10 municípios de residência e de tratamento, matriz residência × tratamento, deslocamento 51,32% |
| `pbi_03_perfil_epidemiologico_tendencias.png` | Tempo médio e volume por ano, faixa etária (50 a 69 anos), idade média 57 |
| `sprint4_arquitetura_lambda.png` | Arquitetura de referência Lambda |
| `sprint4_datasus_ftp_raiz.png` | FTP público do DATASUS |
| `sprint4_datasus_ftp_arquivos_pobr.png` | Arquivos POBR do Painel-Oncologia |
