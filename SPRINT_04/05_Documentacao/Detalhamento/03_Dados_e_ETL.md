# 03 · Dados e ETL

## Fontes

| Fonte | Conteúdo | Uso |
|---|---|---|
| Painel-Oncologia (INCA/DATASUS), extrato POBR | Casos C50, sexo feminino, SP, diagnóstico e início do tratamento | Indicador de prazo |
| Painel-Oncologia, indicadores territoriais | Estabelecimentos CACON/UNACON e mamografias de rastreio por DRS e ano | Oferta e pressão assistencial |
| CNES + deliberações CIB-SP | CNES tratante; nome e habilitação confirmados para 20 unidades | Localizador |
| IBGE (via conjunto aberto kelvins/municipios-brasileiros) | Coordenadas das sedes dos 645 municípios de SP | Distância estimada e mapa |
| Scripts de carga Oracle (`02a`, `02b`) | 645 municípios → DRS; 247 unidades | Dimensões |

## Recorte e tratamento

| Etapa | Resultado |
|---|---|
| Registros brutos | 46.181 |
| Descartados (tratamento anterior ao diagnóstico) | 765 |
| **Casos válidos** | **45.416 (98,34%)** |
| Período de diagnóstico | jan/2022 a abr/2026 (2026 parcial) |
| Residentes fora de SP | 1.778 (agrupados como “Fora do Estado de SP”, DRS-00) |
| Municípios de residência distintos | 1.042 (640 de SP) |
| CNES tratantes distintos | 111 (+3 unidades de referência CIB-SP sem casos) |

## ETL (`etl/build_data.py`)

1. Lê `staging_casos.csv`, os scripts SQL de municípios e unidades, o `data.js` do site anterior e as coordenadas.
2. **Minimiza** os casos: mantém só ano, mês, município de residência, município e CNES de tratamento, tipo e dias.
   Descarta código do caso, data de nascimento e datas exatas → `server/data/casos.csv.gz`.
3. Monta `referencia.json`: DRS e oferta por ano, municípios (com coordenadas projetadas no SVG do mapa),
   unidades, polígonos do mapa e textos metodológicos.
4. Ajusta a projeção do mapa testando duas hipóteses; a equiretangular coloca **91,6%** das sedes dentro do polígono
   da própria DRS (a malha é simplificada).
5. Gera `etl/relatorio_validacao.md` comparando com os números já publicados.

**Validação:** KPI geral e **34 indicadores por DRS** (residência e tratamento) recalculados → **0 divergências**.

## Indicadores

| Indicador | Fórmula |
|---|---|
| % acima de 60 dias | casos com dias > 60 ÷ total × 100 |
| % dentro do prazo | casos com dias ≤ 60 ÷ total × 100 |
| Situação | dentro 0–45 · próximo do limite 46–60 · acima > 60 |
| Faixas | 0–30, 31–45, 46–60, 61–90, 91–120, 121+ |
| Mediana / média | sobre os dias entre diagnóstico e início do tratamento |
| Pressão assistencial | casos do ano ÷ estabelecimentos CACON/UNACON do ano (por DRS) |
| Variação | % acima de 60 no último ano fechado − % no ano anterior (p.p.) |
| Alerta CRÍTICO | ≥ 70% e variação > 0 |
| Alerta ATENÇÃO | variação > +5 p.p. |
| Alerta OPORTUNIDADE | < 55% e variação ≤ 0 |
| Alerta MONITORAR | demais (mínimo de 30 casos por ano) |

## Proteção estatística e de privacidade

| Regra | Onde |
|---|---|
| Grupos com menos de 10 casos: percentual e mediana suprimidos (“<10”) | API do site |
| Rankings e alertas exigem 30 casos | API do site e views da IA (`VW_P60_MUNICIPIO`, `VW_P60_UNIDADE`) |
| Nenhum dado individual sai do servidor | API e views |

## Principais resultados

| Métrica | Valor |
|---|---|
| Acima de 60 dias | **27.830 casos (61,3%)** |
| Mediana · média · maior tempo | 79 · 112,1 · 1.443 dias |
| Faixas | 0–30: 18,5% · 31–45: 10,0% · 46–60: 10,2% · 61–90: 17,2% · 91–120: 12,5% · 121+: 31,5% |
| 2025 vs 2024 (Estado) | 59,1% vs 61,9% acima de 60 dias (−2,8 p.p.); mediana 74 vs 81 dias |
| Pior DRS (acumulado) | DRS XIV São João da Boa Vista, 84,3% |
| Melhor DRS (acumulado) | DRS IX Marília, 44,6% |
| Tratamento com maior atraso | Radioterapia, 85,5% acima de 60 dias (mediana 143 dias) |
| Tratadas fora da DRS de residência | 4.673 casos (10,3%) |
