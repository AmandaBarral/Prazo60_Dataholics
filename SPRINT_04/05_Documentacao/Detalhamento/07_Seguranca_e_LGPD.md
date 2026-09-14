# 07 · Segurança e LGPD

## Autenticação e sessão

| Controle | Implementação |
|---|---|
| Usuário único | `DATAHOLICS` (sem distinção de maiúsculas) |
| Senha | Armazenada só como hash **PBKDF2-SHA256, 600.000 iterações**, sal aleatório; comparação em tempo constante |
| Sessão | Cookie assinado `prazo60_sessao`, HttpOnly, SameSite=Lax, Secure em produção, validade 8 h |
| Força bruta | 5 tentativas erradas por IP bloqueiam por 15 min (HTTP 429) |
| CSRF | POST exige cabeçalho `X-Requested-With: prazo60` e confere `Origin` |
| Rotas protegidas | `/app/*` redireciona para `/login`; `/api/*` responde 401 sem sessão |
| Travessia de diretório | Arquivos da aplicação servidos só dentro de `web/app` |

## Cabeçalhos HTTP

`Content-Security-Policy` (sem scripts externos; iframes só do Power BI) · `Strict-Transport-Security` ·
`X-Frame-Options: DENY` · `X-Content-Type-Options: nosniff` · `Referrer-Policy` · `Permissions-Policy` ·
`Cross-Origin-Opener-Policy: same-origin-allow-popups` (login Microsoft do Power BI) · `X-Robots-Tag: noindex`.
Documentação da API desativada em produção.

## Segredos

| Segredo | Tratamento |
|---|---|
| Senhas Oracle e do wallet | Variáveis de ambiente (Render) e `.env` local ignorado pelo Git |
| Wallet | Secret Files do Render; pasta `wallet/` ignorada pelo Git |
| Chave do Google | Somente em credenciais do banco (`DBMS_CLOUD.CREATE_CREDENTIAL`) |
| Logs | URLs com `?key=` mascaradas antes de gravar |
| Repositório | Verificação automática de padrões de chave antes de cada commit publicado |

**Incidentes durante a configuração:** a chave do Google apareceu duas vezes na conversa (colagem e mensagem de erro
do Oracle). Nas duas vezes a chave foi excluída e recriada; o script e o servidor passaram a mascarar a chave.

## LGPD

| Princípio | Como foi aplicado |
|---|---|
| Minimização | Base do site sem código do caso, data de nascimento ou datas exatas |
| Anonimização | Fonte sem CNS/CPF/nome; nenhum identificador em qualquer camada |
| Agregação | API devolve só agregados; supressão abaixo de 10 casos; rankings com ≥ 30 |
| IA | Usuário do site enxerga apenas 8 views agregadas; tabelas de nível caso revogadas |
| Finalidade | Monitoramento da lei e gestão pública; não serve para decisão clínica individual |
| Transparência | Fontes, fórmulas, regras, premissas e limitações visíveis na plataforma |
| Compartilhamento | O Google recebe metadados das views e a pergunta (não recebe linhas de pacientes) |

## Nunca exibido

Nome · CPF · CNS · endereço residencial · telefone · data de nascimento · qualquer registro individual.

## Testes automatizados de segurança

Senha não armazenada em texto puro · login válido/inválido · CSRF · bloqueio por tentativas · logout · 6 rotas de API
exigem login · aplicação redireciona sem login · travessia de diretório bloqueada · base de casos não é pública ·
cabeçalhos de segurança · IA não inventa resposta sem integração · extração segura de SQL (recusa comandos encadeados).
