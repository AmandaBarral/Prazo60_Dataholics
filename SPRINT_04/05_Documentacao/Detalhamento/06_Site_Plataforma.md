# 06 · Site / Plataforma

## Páginas

| Menu | Pergunta | O que mostra |
|---|---|---|
| **Início** | As pacientes iniciam em 60 dias? | Hero, evidência central (61,3%), jornada do dado à decisão, caso de uso completo |
| **Visão Executiva** | Qual a situação e quem precisa de atenção? | 8 KPIs com tendência, série mensal, distância até a meta, comparação anual, recomendações |
| **Panorama dos 60 Dias** | Como os casos se distribuem? | Régua temporal, situação (dentro/limite/acima), faixas, faixas por ano, tipos de tratamento |
| **Demanda & Oferta** | Onde há mais pressão? | KPIs de demanda/oferta/pressão, dispersão, barras, 4 rankings, sankey de fluxos |
| **Mapa de Atendimento** | Onde estão os problemas? | 17 DRS coloridas por métrica, municípios, unidades, painel de detalhe, clique filtra a plataforma |
| **Onde estão os gargalos?** | Quem precisa de atenção? | Alertas por regra, municípios críticos, fatores relacionados, motor de apoio à decisão |
| **Para onde encaminhar?** | Quais alternativas existem? | Localizador por município, onde as residentes tratam hoje, unidades compatíveis com distância estimada |
| **Simulação** | O que acontece se redistribuirmos? | Simulador em 4 etapas, 5 cenários, premissas ajustáveis, resultado com limitações |
| **Power BI** | Análise aprofundada | Relatório incorporado, guia de incorporação e riscos |
| **Inteligência Artificial** | Pergunte aos dados | Chat com Select AI, SQL gerado, arquitetura, evidências da Sprint 3, APIs |
| **Dados & Metodologia** | O que sustenta o diagnóstico? | Fontes, pipeline e arquitetura, qualidade, central de indicadores, privacidade, limitações |
| **Sobre o Prazo60** | Quem somos | Problema, lei, objetivo, metodologia, impacto, ética, equipe |

**Filtros globais:** ano, mês, DRS, município, estabelecimento, tipo de tratamento, situação do prazo e dimensão
(residência ou local de tratamento), com chips e “Limpar filtros”. Persistem na sessão do navegador.

**Modo Apresentação:** 12 etapas (Problema → Impacto → Dados → Diagnóstico → Demanda & Oferta → Gargalos → Localizador
→ Simulação → Power BI → IA → Solução → Impacto esperado), tela cheia, setas do teclado e Esc.

**Selos:** DADO REAL · ESTIMATIVA · SIMULAÇÃO · PROJEÇÃO · DEMONSTRAÇÃO · PREMISSA.

## Motor de apoio à decisão

| Cartão | Regra | Resultado atual |
|---|---|---|
| ATENÇÃO | Maior % acima de 60 dias no último ano fechado (≥ 30 casos) | DRS XIV São João da Boa Vista, 82,1% em 2025 |
| RISCO | Maior piora entre os dois últimos anos | DRS XII Registro, +10,4 p.p. |
| OPORTUNIDADE | Menor % com tendência estável ou de melhora (≥ 100 casos) | DRS IX Marília, 38,6% (−9,1 p.p.) |
| AÇÃO SUGERIDA | DRS mais próxima da crítica com ≥ 10 p.p. a menos | Avaliar fluxo complementar DRS XIV → DRS X Piracicaba |

## Localizador

Ordena unidades por: (1) faixa de distância estimada (linha reta entre sedes municipais), (2) compatibilidade
(habilitação CIB-SP confirmada antes de unidade com ≥ 30 casos C50 tratados), (3) informações disponíveis.
Nunca afirma vaga. Exemplo São Bernardo do Campo: 434 casos de residentes, 56,5% acima de 60 dias, mediana 71 dias,
10,6% tratadas fora do município.

## Simulador de encaminhamento

- **Dados reais:** fluxo das residentes por unidade e distribuição de dias de espera (2024–2025), distância estimada.
- **Premissas ajustáveis:** utilização de base das unidades (padrão 70%) e parte da espera sensível à fila (padrão 50%).
- **Modelo:** fator = (1 − q) + q · g(ρ₀·L)/g(ρ₀), com g(ρ) = ρ/(1 − ρ), ρ limitado a 0,97.
- **Cenários:** capacidade normal, demanda elevada no município, unidade indisponível, aumento de demanda na região,
  redistribuição regional.
- **Exemplo (São Bernardo do Campo, redistribuir 30% da unidade principal):** real 62 dias / 51,6%; linha de base do
  modelo 66 dias / 54,8%; simulado 64,2 dias / 52,9% (−1,8 dias, −1,9 p.p.); ~15 pacientes/ano mudam de unidade;
  deslocamento médio 1,7 → 2,4 km.

## API

| Método | Rota | Acesso | Função |
|---|---|---|---|
| POST | `/api/auth/login` | público | Login (JSON + `X-Requested-With`) |
| POST | `/api/auth/logout` | sessão | Sair |
| GET | `/api/auth/sessao` | sessão | Usuário e expiração |
| GET | `/api/saude` | público | Verificação de saúde |
| GET | `/api/config` | sessão | Power BI e Select AI |
| GET | `/api/referencia` | sessão | Mapa, DRS, municípios, textos |
| GET | `/api/opcoes` | sessão | Opções dos filtros |
| GET | `/api/painel` | sessão | Todos os agregados do recorte + recomendações |
| GET | `/api/localizador` | sessão | Unidades compatíveis para um município |
| GET | `/api/simulacao/contexto` | sessão | Etapas 1 e 2 do simulador |
| POST | `/api/simulacao` | sessão | Executa um cenário |
| POST | `/api/ia/perguntar` | sessão | Pergunta ao Select AI |
