-- ============================================================
-- 05. SELECT AI COM GOOGLE GEMINI · roda tudo de uma vez (F5), como ADMIN
-- 1 libera a rede · 2 grava a chave · 3 acha um modelo Gemini que funciona
-- 4 cria o perfil PRAZO60_AI_GOOGLE · 5 testa showsql, runsql e narrate
-- Leva de 1 a 2 minutos. NUNCA salve este arquivo com a chave preenchida.
-- ============================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  -- >>> COLE A CHAVE DO GOOGLE AI STUDIO ENTRE AS ASPAS <<<
  c_chave    CONSTANT VARCHAR2(300) := 'COLE_A_CHAVE_AQUI';

  c_perfil   CONSTANT VARCHAR2(30)  := 'PRAZO60_AI_GOOGLE';
  c_pergunta CONSTANT VARCHAR2(200) := 'Quantos casos ultrapassaram o prazo de 60 dias?';
  c_tabelas  CONSTANT VARCHAR2(1000) :=
    '[{"owner":"ADMIN","name":"TB_CASO_PACIENTE"},{"owner":"ADMIN","name":"TB_TRATAMENTO"},'
 || '{"owner":"ADMIN","name":"TB_UNIDADE_SAUDE"},{"owner":"ADMIN","name":"TB_MUNICIPIO"},'
 || '{"owner":"ADMIN","name":"TB_DRS"},{"owner":"ADMIN","name":"TB_STATUS_PRAZO"},'
 || '{"owner":"ADMIN","name":"TB_TIPO_TRATAMENTO"}]';
  modelos    SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(
               'gemini-2.5-flash', 'gemini-flash-latest', 'gemini-2.5-flash-lite',
               'gemini-flash-lite-latest', 'gemini-3-flash-preview');
  modelo_ok  VARCHAR2(100);
  sql_gerado VARCHAR2(4000);

  PROCEDURE log(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;

  PROCEDURE apagar_perfil IS
  BEGIN DBMS_CLOUD_AI.DROP_PROFILE(c_perfil); EXCEPTION WHEN OTHERS THEN NULL; END;

  PROCEDURE criar_perfil(p_modelo VARCHAR2, p_restrito BOOLEAN) IS
  BEGIN
    apagar_perfil;
    DBMS_CLOUD_AI.CREATE_PROFILE(
      profile_name => c_perfil,
      attributes   => '{"provider":"google","credential_name":"GOOGLE_CRED","model":"' || p_modelo || '",'
                   || CASE WHEN p_restrito THEN '"enforce_object_list":true,' END
                   || '"object_list":' || c_tabelas || '}');
  END;

  FUNCTION perguntar(p_acao VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN DBMS_LOB.SUBSTR(DBMS_CLOUD_AI.GENERATE(prompt => c_pergunta, profile_name => c_perfil, action => p_acao), 3900, 1);
  EXCEPTION WHEN OTHERS THEN
    RETURN 'ERRO: ' || SUBSTR(REPLACE(SQLERRM, CHR(10), ' '), 1, 300);
  END;
BEGIN
  IF c_chave NOT LIKE 'AQ.%' AND c_chave NOT LIKE 'AIza%' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Cole a chave do Google AI Studio na linha c_chave antes de rodar.');
  END IF;

  -- 1. Rede
  BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
      host => 'generativelanguage.googleapis.com',
      ace  => xs$ace_type(privilege_list => xs$name_list('http'),
                          principal_name => 'ADMIN',
                          principal_type => xs_acl.ptype_db));
    log('[OK]    1. Rede liberada para o Google');
  EXCEPTION WHEN OTHERS THEN
    log('[AVISO] 1. Rede: ' || SQLERRM);
  END;

  -- 2. Credencial
  BEGIN DBMS_CLOUD.DROP_CREDENTIAL('GOOGLE_CRED'); EXCEPTION WHEN OTHERS THEN NULL; END;
  DBMS_CLOUD.CREATE_CREDENTIAL(credential_name => 'GOOGLE_CRED', username => 'GOOGLE', password => c_chave);
  log('[OK]    2. Credencial GOOGLE_CRED gravada');

  -- 3. Primeiro modelo Gemini que responder
  FOR i IN 1 .. modelos.COUNT LOOP
    criar_perfil(modelos(i), FALSE);
    sql_gerado := perguntar('showsql');
    IF sql_gerado LIKE 'ERRO:%' THEN
      log('[FALHA] 3. ' || modelos(i) || ' -> ' || sql_gerado);
      DBMS_SESSION.SLEEP(12);
    ELSE
      modelo_ok := modelos(i);
      log('[OK]    3. Modelo que funcionou: ' || modelo_ok);
      EXIT;
    END IF;
  END LOOP;

  IF modelo_ok IS NULL THEN
    apagar_perfil;
    log('');
    log('>>> Nenhum modelo respondeu. Me mande as linhas [FALHA] acima (sem a chave).');
    log('>>> "API key not valid" = chave errada · ORA-24247 = rede · 429 = limite gratuito, espere 1 min e rode de novo.');
    RETURN;
  END IF;

  -- 4. Perfil definitivo, restrito as 7 tabelas quando o banco aceitar
  BEGIN
    criar_perfil(modelo_ok, TRUE);
    log('[OK]    4. Perfil ' || c_perfil || ' criado (IA restrita as 7 tabelas)');
  EXCEPTION WHEN OTHERS THEN
    criar_perfil(modelo_ok, FALSE);
    log('[OK]    4. Perfil ' || c_perfil || ' criado');
  END;

  -- 5. Testes com a base completa
  log('');
  log('--- 5a. SQL gerado (showsql) ---');
  log(sql_gerado);
  DBMS_SESSION.SLEEP(20);
  log('');
  log('--- 5b. Resultado (runsql) · esperado cerca de 27.944 ---');
  log(perguntar('runsql'));
  DBMS_SESSION.SLEEP(20);
  log('');
  log('--- 5c. Resposta em texto (narrate) ---');
  log(perguntar('narrate'));
  log('');
  log('Concluido. APAGUE A CHAVE desta aba, limpe o Historico e feche SEM SALVAR.');
END;
/
