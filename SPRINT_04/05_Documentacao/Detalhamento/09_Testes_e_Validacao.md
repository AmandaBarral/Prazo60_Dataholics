# 09 · Testes e validação

## 1. Validação do ETL

`etl/relatorio_validacao.md` — KPI geral (45.416 · 61,3% · 38,7% · mediana 79 · média 112,1 · máximo 1.443) e
**34 indicadores por DRS** (17 por residência, 17 por local de tratamento) recalculados a partir dos casos:
**0 divergências** em relação aos números publicados.

## 2. Testes automatizados (`python -m pytest -q` → 35 passaram)

| Grupo | Testes |
|---|---|
| Autenticação | senha só como hash; login válido e sem distinção de maiúsculas; 3 logins inválidos; CSRF; bloqueio por tentativas; logout |
| Proteção | 6 rotas de API exigem login; aplicação redireciona; travessia de diretório; base de casos não pública; cabeçalhos de segurança |
| Números | KPIs iguais ao site anterior; classificação dos alertas igual à publicada; faixas somam o total; filtros combinados com supressão; filtros inválidos recusados; nenhum campo individual na API; recomendações com fundamento |
| Localizador e simulação | São Bernardo do Campo (unidade ≤ 10 km, aviso de vaga); os 5 cenários; município pequeno recusado |
| Integrações | link do Power BI convertido para `reportEmbed`; IA não inventa resposta sem configuração; extração de SQL do Select AI |

## 3. Validação da carga Oracle (`04_verificar_depois.sql`)

| Verificação | Esperado | Obtido |
|---|---|---|
| Totais | 45.416 staging · 45.616 casos/tratamentos · 646 municípios · 247 unidades | idêntico |
| Código IBGE repetido | nenhuma linha | nenhuma linha |
| Casos que não viraram tratamento | nenhuma linha | nenhuma linha |
| Indicador geral | 45.416 · 61,3% · 79 | 45.416 · 61,3 · 79 |
| 18 grupos por DRS | iguais ao site | iguais (ex.: DRS-00 1.778/70,8; DRS-01 16.568/60,2; DRS-15 2.309/64,7; DRS-17 2.940/55,6) |

## 4. Camada analítica (`07_camada_analitica_select_ai.sql`)

45.416 casos e 27.830 acima de 60 dias nas views; DRS XII - Registro com +10,4 p.p. no topo da piora.

## 5. Testes do Select AI

- Script `scripts/testar_select_ai.py` (conexão, perfil, acesso aos dados, pergunta): 4× `[OK]`.
- Script `scripts/atualizar_perfil_views.py`: 6 de 6 perguntas respondidas em 1,2–3,9 s (ver `05_Select_AI.md`).

## 6. Testes no navegador

Todas as 12 páginas percorridas localmente sem erros de console da aplicação; fluxo de login, filtros, mapa,
localizador (exemplo São Bernardo), simulação completa (4 etapas) e perguntas à IA com resultado e SQL.
Responsividade conferida em 375 px (sem rolagem horizontal) e menu recolhível.
Capturas em `05_Evidencias/capturas`.

## 7. Produção

`/api/saude` → 200 com 45.416 casos carregados; login com CSP ativo; deploys “Live”.
