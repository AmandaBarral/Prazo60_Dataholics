# 11 · Histórico do projeto e decisões

Registro das etapas de desenvolvimento, problemas encontrados e decisões tomadas.

| # | Etapa | Problema ou decisão | Resultado |
|---|---|---|---|
| 1 | Análise do site anterior | `index.html` de 855 KB com imagens em base64; simulação exibia “ocupação” calculada a partir do número da DRS (dado inventado); filtros que não alteravam todos os gráficos | Nova plataforma preservando identidade visual, indicadores e textos; simulação refeita sobre dados reais com premissas explícitas |
| 2 | Hospedagem | Opções Render, Oracle Cloud VM ou só preparar | **Render** escolhido pelo grupo |
| 3 | Distância estimada | Coordenadas municipais ausentes nos arquivos | Download aprovado do conjunto aberto derivado do IBGE |
| 4 | ETL | Dados de nível caso com data de nascimento | Base minimizada no servidor; validação 34/34 DRS |
| 5 | Plataforma | Requisitos do prompt mestre (12 páginas, login, filtros, localizador, simulador, BI, IA) | FastAPI + frontend modular; 33 testes iniciais |
| 6 | Power BI | Link de visualização não pode ser incorporado | Conversão automática para `reportEmbed` e ajuste de COOP para o login Microsoft |
| 7 | Banco compartilhado | Dúvida se o banco do Eduardo e da colega eram diferentes | Mesmo PDB (`GC9981D36774D5D_PRAZO60DB`), ambos como ADMIN |
| 8 | Carga completa | Status em cores; IBGE 354990 duplicado (Sprint 3) causando ORA-00001 | Scripts e cadastros corrigidos; 45.416 casos conferidos |
| 9 | Limpeza | 8 tabelas de outra disciplina no schema | Removidas após conferir dependências |
| 10 | Select AI OCI | HTTP 429 em todos os modelos ativos; modelos Cohere aposentados | Conta OCI sem cota; migração para Google Gemini |
| 11 | Google AI Studio | Chave exposta duas vezes na conversa | Chaves recriadas; mascaramento em scripts e logs |
| 12 | Usuário do site | Evitar ADMIN e dados individuais | `PRAZO60_APP` somente leitura; view sem data de nascimento |
| 13 | Wallet | `.env` salvo como `.env.txt` pelo Bloco de Notas | Renomeado; teste local 4× OK |
| 14 | Estabilidade | `gemini-flash-latest` com 503 e travamento | `gemini-flash-lite-latest`; uma chamada por pergunta; tempo máximo |
| 15 | Publicação | Git com credencial de outra conta | Remoto com usuário explícito; push e Blueprint no Render |
| 16 | Qualidade da IA | Erros em evolução, meses e demanda × oferta; rankings com 1 caso | Camada analítica `VW_P60_*`, contexto por tipo de pergunta, novas tentativas |
| 17 | Script na conexão errada | ORA-01031 ao criar views como `PRAZO60_APP` | Trava no início do script; execução como ADMIN |
| 18 | Documentação | Consolidação final | Esta pasta, capturas de tela e relatório em PDF |
