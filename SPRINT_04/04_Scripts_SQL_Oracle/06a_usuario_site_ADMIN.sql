-- ============================================================
-- 06a. USUARIO DO SITE · rodar conectado como ADMIN (F5)
-- Cria PRAZO60_APP (somente leitura), uma view de casos SEM data de nascimento,
-- e libera a rede do Google para esse usuario. Pode rodar mais de uma vez.
-- ============================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  -- >>> DEFINA A SENHA DO USUARIO DO SITE ENTRE AS ASPAS <<<
  -- 12 a 30 caracteres, com maiuscula, minuscula e numero; sem aspas duplas e sem a palavra admin.
  c_senha CONSTANT VARCHAR2(60) := 'DEFINA_A_SENHA_AQUI';

  PROCEDURE log(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  PROCEDURE exec(p VARCHAR2) IS BEGIN EXECUTE IMMEDIATE p; END;
BEGIN
  IF c_senha LIKE 'DEFINA_A_SENHA%' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Defina a senha do PRAZO60_APP na linha c_senha antes de rodar.');
  END IF;

  BEGIN
    exec('CREATE USER PRAZO60_APP IDENTIFIED BY "' || c_senha || '"');
    log('[OK] 1. Usuario PRAZO60_APP criado');
  EXCEPTION WHEN OTHERS THEN
    IF SQLCODE = -1920 THEN
      exec('ALTER USER PRAZO60_APP IDENTIFIED BY "' || c_senha || '" ACCOUNT UNLOCK');
      log('[OK] 1. Usuario PRAZO60_APP ja existia: senha atualizada');
    ELSE
      RAISE;
    END IF;
  END;

  exec('GRANT CREATE SESSION TO PRAZO60_APP');
  exec('GRANT EXECUTE ON DBMS_CLOUD TO PRAZO60_APP');
  exec('GRANT EXECUTE ON DBMS_CLOUD_AI TO PRAZO60_APP');
  exec('ALTER USER PRAZO60_APP QUOTA 10M ON DATA');
  log('[OK] 2. Permissoes de conexao e Select AI concedidas');

  -- A IA do site nunca enxerga DATA_NASCIMENTO
  exec('CREATE OR REPLACE VIEW ADMIN.VW_CASO_PACIENTE AS '
    || 'SELECT ID_CASO, COD_CASO, ESTAGIO_TUMOR, DATA_DIAGNOSTICO, ID_UNIDADE_DIAGNOSTICO, ID_MUNICIPIO_RESIDENCIA '
    || 'FROM ADMIN.TB_CASO_PACIENTE');
  FOR t IN (SELECT column_value AS nome FROM TABLE(SYS.ODCIVARCHAR2LIST(
              'VW_CASO_PACIENTE', 'TB_TRATAMENTO', 'TB_UNIDADE_SAUDE', 'TB_MUNICIPIO',
              'TB_DRS', 'TB_STATUS_PRAZO', 'TB_TIPO_TRATAMENTO'))) LOOP
    exec('GRANT SELECT ON ADMIN.' || t.nome || ' TO PRAZO60_APP');
  END LOOP;
  log('[OK] 3. Leitura liberada em 7 objetos (casos via view, sem data de nascimento)');

  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host => 'generativelanguage.googleapis.com',
    ace  => xs$ace_type(privilege_list => xs$name_list('http'),
                        principal_name => 'PRAZO60_APP',
                        principal_type => xs_acl.ptype_db));
  log('[OK] 4. Rede do Google liberada para o PRAZO60_APP');
  log('');
  log('Proximo: criar a conexao PRAZO60_APP no SQL Developer e rodar 06b_select_ai_site_APP.sql.');
  log('Apague a senha desta aba e feche sem salvar.');
END;
/
