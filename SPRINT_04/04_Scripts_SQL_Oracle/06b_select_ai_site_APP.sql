-- ============================================================
-- 06b. SELECT AI DO SITE · rodar conectado como PRAZO60_APP (F5)
-- Credencial e perfil pertencem a quem os cria: por isso o usuario do site
-- precisa dos seus proprios. Usa a MESMA chave do Google AI Studio.
-- ============================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  -- >>> COLE A CHAVE DO GOOGLE AI STUDIO ENTRE AS ASPAS <<<
  c_chave  CONSTANT VARCHAR2(300) := 'COLE_A_CHAVE_AQUI';

  c_perfil CONSTANT VARCHAR2(30) := 'PRAZO60_AI_GOOGLE';
  c_attrs  CONSTANT VARCHAR2(2000) :=
       '{"provider":"google","credential_name":"GOOGLE_CRED","model":"gemini-flash-lite-latest",'
    || '"enforce_object_list":true,"object_list":['
    || '{"owner":"ADMIN","name":"VW_CASO_PACIENTE"},{"owner":"ADMIN","name":"TB_TRATAMENTO"},'
    || '{"owner":"ADMIN","name":"TB_UNIDADE_SAUDE"},{"owner":"ADMIN","name":"TB_MUNICIPIO"},'
    || '{"owner":"ADMIN","name":"TB_DRS"},{"owner":"ADMIN","name":"TB_STATUS_PRAZO"},'
    || '{"owner":"ADMIN","name":"TB_TIPO_TRATAMENTO"}]}';
  resposta VARCHAR2(4000);

  PROCEDURE log(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
BEGIN
  IF c_chave NOT LIKE 'AQ.%' AND c_chave NOT LIKE 'AIza%' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Cole a chave do Google AI Studio na linha c_chave antes de rodar.');
  END IF;
  IF USER <> 'PRAZO60_APP' THEN
    RAISE_APPLICATION_ERROR(-20002, 'Este script deve rodar conectado como PRAZO60_APP (conectado agora: ' || USER || ').');
  END IF;

  BEGIN DBMS_CLOUD.DROP_CREDENTIAL('GOOGLE_CRED'); EXCEPTION WHEN OTHERS THEN NULL; END;
  DBMS_CLOUD.CREATE_CREDENTIAL(credential_name => 'GOOGLE_CRED', username => 'GOOGLE', password => c_chave);
  log('[OK] 1. Credencial GOOGLE_CRED do site gravada');

  BEGIN DBMS_CLOUD_AI.DROP_PROFILE(c_perfil); EXCEPTION WHEN OTHERS THEN NULL; END;
  DBMS_CLOUD_AI.CREATE_PROFILE(profile_name => c_perfil, attributes => c_attrs);
  log('[OK] 2. Perfil ' || c_perfil || ' criado para o site');

  BEGIN
    resposta := DBMS_LOB.SUBSTR(DBMS_CLOUD_AI.GENERATE(
                  prompt       => 'Quantos casos ultrapassaram o prazo de 60 dias?',
                  profile_name => c_perfil,
                  action       => 'narrate'), 3900, 1);
    log('[OK] 3. Teste: ' || resposta);
  EXCEPTION WHEN OTHERS THEN
    log('[FALHA] 3. ' || SUBSTR(REGEXP_REPLACE(REPLACE(SQLERRM, CHR(10), ' '), 'key=[^ &]+', 'key=***'), 1, 300));
  END;
  log('');
  log('Apague a chave desta aba, limpe o Historico e feche SEM SALVAR.');
END;
/
