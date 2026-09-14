# 05 · Prazo60 AI (Oracle Select AI)

## Linha do tempo

| Fase | O que aconteceu |
|---|---|
| Sprint 3 | Select AI com **OCI Generative AI** (credencial `OCI_CRED`, perfil `PRAZO60_AI`, 7 tabelas, 200 casos). Testes `showsql` e `runsql` validados. |
| Carga completa | Base passou a 45.416 casos. |
| 13/09/2026 · OCI | Todas as chamadas voltaram **HTTP 429**. Lista de modelos consultada pelo próprio banco: vários modelos Cohere aposentados em 31/08/2026; o Cohere R+ devolveu 400 “retired”; **todos** os modelos ativos (Cohere, Meta, Google) devolveram 429 → conta sem cota de Generative AI sob demanda. |
| Decisão | Trocar o provedor para **Google AI Studio (Gemini)**, suportado pelo Select AI (`provider: google`), sem custo no plano gratuito. |
| Configuração | ACL de rede para `generativelanguage.googleapis.com`, credencial `GOOGLE_CRED`, perfil `PRAZO60_AI_GOOGLE`. Modelo `gemini-flash-latest` respondeu 27.944 (base com os 200 da Sprint 3). |
| Site | Usuário `PRAZO60_APP` com credencial e perfil próprios; wallet no Render. |
| Instabilidade | `gemini-flash-latest` passou a devolver 503 e a travar (>60 s). Perfil trocado para **`gemini-flash-lite-latest`** (~2 s). |
| Qualidade | Perguntas de evolução, meses e demanda × oferta falhavam; rankings mostravam municípios com 1 caso a 100%. Criada a **camada analítica `VW_P60_*`** e o contexto por tipo de pergunta. |

## Arquitetura final

```text
Pergunta (site) → FastAPI /api/ia/perguntar (sessão + limite de 20/h)
  → DBMS_CLOUD_AI.GENERATE(prompt = contexto + pergunta, profile = PRAZO60_AI_GOOGLE, action = 'showsql')
      → Gemini recebe metadados e comentários das 8 views → devolve SQL
  → servidor extrai uma única consulta SELECT/WITH (aceita bloco ```sql```)
  → executa como PRAZO60_APP (somente views agregadas, máx. 50 linhas, 45 s)
  → resposta: colunas + linhas + SQL gerado (para auditoria)
```

Uma única chamada ao modelo por pergunta (em vez de `showsql` + `narrate`): mais rápido, menos cota e o resultado vem
direto do banco, não de um texto gerado.

## Perfil do site (`PRAZO60_AI_GOOGLE`, usuário `PRAZO60_APP`)

| Atributo | Valor |
|---|---|
| `provider` | `google` |
| `credential_name` | `GOOGLE_CRED` |
| `model` | `gemini-flash-lite-latest` |
| `enforce_object_list` | `true` |
| `comments` | `true` |
| `object_list` | 8 views `ADMIN.VW_P60_*` |

## Contexto enviado ao modelo (resumo)

- Base: câncer de mama C50, SUS-SP, 2022–2026 (2026 parcial); usar só `VW_P60_*`; região = DRS.
- Evolução → `VW_P60_DRS_ANO` ou `VARIACAO_PP_2024_2025` (positivo = piora).
- Últimos meses → `VW_P60_RESUMO_MES`, meses de 2025 (os de 2026 ainda estão incompletos).
- Demanda × oferta → `PRESSAO_CASOS_POR_ESTABELECIMENTO` em `VW_P60_DRS`.
- Proximidade → mesma DRS (não há distância na base).
- Excluir `DRS-00` ao comparar regiões; `SELECT DISTINCT` em junções; limitar rankings a 10 linhas.

## Robustez

| Situação | Tratamento |
|---|---|
| Google 503/429 | Nova tentativa após 3 s; depois, mensagem “modelo sobrecarregado” |
| Chamada > 45 s | Interrompida, mensagem clara |
| Modelo responde texto em vez de SQL | Pede de novo exigindo SQL (até 3 tentativas) |
| SQL falha no banco | Pede de novo informando o código ORA |
| Nada funcionou | 422 + perguntas sugeridas clicáveis |
| Erro com URL `?key=` | Chave mascarada (`key=***`) no log |

## Testes com a base completa (13/09/2026)

| Pergunta | Resposta obtida |
|---|---|
| Qual região apresentou pior evolução? | DRS XII - Registro, +10,4 p.p. |
| Como a situação mudou nos últimos meses? | 2025: 57,1% (jul) → 53,8% (dez) acima de 60 dias |
| Onde existe maior pressão entre demanda e oferta? | DRS II Araçatuba (220 casos por estabelecimento), DRS V Barretos (209), DRS VIII Franca (192) |
| Quais unidades estão próximas de municípios críticos? | Unidades na mesma DRS dos municípios com maior % acima de 60 dias |
| Quais municípios possuem maior percentual acima de 60 dias? | Mococa 93,5% (77 casos), Casa Branca 90%, Mogi Mirim 89,6% |
| Quantos casos ultrapassaram o prazo de 60 dias? | 27.830 |
| Quais regiões têm o maior percentual acima de 60 dias? | DRS XIV 84,3%, DRS V 76,9%, DRS II 75,3% |

## Segurança e dados enviados ao Google

- O Gemini recebe **nomes e comentários das views** e a pergunta; o resultado é executado no Oracle e **não** é enviado
  ao modelo. O usuário do site só enxerga agregados (rankings com ≥ 30 casos).
- No plano gratuito o Google pode usar requisições para melhorar os modelos: decisão consciente do grupo.
- A chave foi exposta em conversa duas vezes durante a configuração e **foi substituída** em seguida. A credencial
  pode ser trocada sem mexer no perfil (ver `10_Operacao_e_Manutencao.md`).

## Voltar para a OCI

Se a conta OCI recuperar créditos/cota: criar perfil com `provider: oci` e `model` explícito ativo, apontando para as
mesmas views, e alterar `SELECT_AI_PERFIL` no Render. O código do site não muda.
