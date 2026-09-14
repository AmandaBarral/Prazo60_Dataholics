# 10 · Operação e manutenção

## Antes de uma apresentação

1. Oracle Cloud › Prazo60DB deve estar **Available** (Always Free para após 7 dias sem conexão → **Start**).
2. Abrir https://prazo60.onrender.com alguns minutos antes (hibernação do plano gratuito).
3. Na página *Inteligência Artificial*, fazer uma pergunta de teste.
4. Silenciar notificações e fechar arquivos com senhas se for gravar a tela.

## Rodar localmente

```bash
cd C:\Projetos\prazo60-plataforma
pip install -r requirements.txt
uvicorn server.main:app --reload --port 8000
```

Abrir http://localhost:8000. Com `.env` preenchido e `SELECT_AI_HABILITADO=true`, a IA também funciona localmente.

## Trocar a senha do site

```bash
python scripts/gerar_hash_senha.py
```

Colar o resultado em `APP_PASSWORD_HASH` no Render › Environment › Save changes.

## Trocar a chave do Google (sem mexer no perfil)

1. Google AI Studio › API keys: excluir a chave antiga e criar outra.
2. No SQL Developer, **em cada usuário** (ADMIN e PRAZO60_APP), rodar trocando só a chave:

```sql
BEGIN
  DBMS_CLOUD.DROP_CREDENTIAL('GOOGLE_CRED');
  DBMS_CLOUD.CREATE_CREDENTIAL(credential_name => 'GOOGLE_CRED', username => 'GOOGLE', password => 'COLE_A_CHAVE_AQUI');
END;
/
```

3. Apagar a chave da aba, limpar o Histórico e fechar sem salvar.

## Trocar o modelo Gemini

```sql
EXEC DBMS_CLOUD_AI.SET_ATTRIBUTE('PRAZO60_AI_GOOGLE', 'model', 'NOME_DO_MODELO');
```

Rodar conectado como `PRAZO60_APP`. Atualizar `SELECT_AI_PROVEDOR` no Render (texto exibido).

## Atualizar o Power BI

Alterar `POWERBI_EMBED_URL` no Render. Aceita link do relatório, “Site ou portal” (`reportEmbed`) ou “Publicar na Web” (`view?r=`).

## Atualizar os dados

1. Substituir as fontes e rodar `python etl/build_data.py` (confere `etl/relatorio_validacao.md`).
2. `python -m pytest -q`.
3. Commit e push (auto-deploy).
4. No Oracle: repetir a carga e reexecutar `07_camada_analitica_select_ai.sql` (os anos 2024/2025 da view `VW_P60_DRS`
   são fixos e devem ser atualizados quando houver um novo ano fechado).

## Problemas comuns

| Sintoma | Causa provável | Ação |
|---|---|---|
| Site demora ~50 s | Hibernação do Render | Aguardar |
| IA: “modelo sobrecarregado” | Google 503/429 | Aguardar alguns segundos; se persistir, trocar para outro modelo Gemini |
| IA: “Conexão Oracle indisponível” | Banco parado, senha ou Secret Files | Start no banco; conferir variáveis e arquivos no Render |
| IA não entende a pergunta | Pergunta fora das views | Usar as perguntas sugeridas; incluir região, ano ou métrica |
| Script SQL com ORA-01031 | Conexão errada | Conferir a caixa de conexão da planilha (canto superior direito) |
| Push recusado “Repository not found” | Git usando outra conta | `git remote set-url origin https://bambulimeduardo-design@github.com/bambulimeduardo-design/prazo60-plataforma.git` |
