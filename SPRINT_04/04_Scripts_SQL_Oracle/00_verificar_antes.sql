-- ============================================================
-- 00. VERIFICAR ANTES DA CARGA (rodar como ADMIN, antes de tudo)
--
-- Os scripts de carga NAO criam DRS, tipos de tratamento nem status de prazo:
-- eles supoem que isso ja existe desde a Sprint 3. Se algo faltar, os casos
-- somem em silencio (JOIN) ou a residencia cai em "Fora do Estado de SP".
-- ============================================================

-- 1. As 17 DRS de SP existem? Esperado: 17
SELECT COUNT(*) AS drs_sp FROM TB_DRS WHERE COD_DRS BETWEEN 'DRS-01' AND 'DRS-17';

-- 2. Os 4 tipos de tratamento da base existem com o nome exato? Esperado: 4
SELECT NOME_TIPO_TRATAMENTO FROM TB_TIPO_TRATAMENTO
WHERE NOME_TIPO_TRATAMENTO IN ('Quimioterapia', 'Radioterapia', 'Cirurgia', 'Quimioterapia + Radioterapia');

-- 3. Os 5 status de prazo existem? Esperado: 5
SELECT COD_STATUS FROM TB_STATUS_PRAZO
WHERE COD_STATUS IN ('Verde', 'Amarelo', 'Laranja', 'Vermelho', 'Vencido');

-- 4. A coluna de residencia ja existe? 1 = pule o arquivo 00_alterar_schema_residencia.sql
SELECT COUNT(*) AS coluna_residencia_existe FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'TB_CASO_PACIENTE' AND COLUMN_NAME = 'ID_MUNICIPIO_RESIDENCIA';

-- 5. A staging ja existe? 1 = NAO rode 01_criar_staging.sql; limpe com o bloco C abaixo
SELECT COUNT(*) AS staging_existe FROM USER_TABLES WHERE TABLE_NAME = 'STG_CASOS_PRAZO60';

-- 6. Municipios ja cadastrados (Sprint 3). Anote quantos sao: o passo 04 confere duplicidade.
SELECT ID_MUNICIPIO, NOME_MUNICIPIO, COD_IBGE FROM TB_MUNICIPIO ORDER BY ID_MUNICIPIO;


-- ============================================================
-- CORRECOES (rode apenas o bloco do item que nao bateu)
-- ============================================================

-- A. Item 1 deu menos de 17: cria as DRS que faltam (nao altera as existentes)
MERGE INTO TB_DRS tgt
USING (
  SELECT 'DRS-01' COD_DRS, 'DRS I - Grande São Paulo' NOME_DRS FROM dual UNION ALL
  SELECT 'DRS-02', 'DRS II - Araçatuba' FROM dual UNION ALL
  SELECT 'DRS-03', 'DRS III - Araraquara' FROM dual UNION ALL
  SELECT 'DRS-04', 'DRS IV - Baixada Santista' FROM dual UNION ALL
  SELECT 'DRS-05', 'DRS V - Barretos' FROM dual UNION ALL
  SELECT 'DRS-06', 'DRS VI - Bauru' FROM dual UNION ALL
  SELECT 'DRS-07', 'DRS VII - Campinas' FROM dual UNION ALL
  SELECT 'DRS-08', 'DRS VIII - Franca' FROM dual UNION ALL
  SELECT 'DRS-09', 'DRS IX - Marília' FROM dual UNION ALL
  SELECT 'DRS-10', 'DRS X - Piracicaba' FROM dual UNION ALL
  SELECT 'DRS-11', 'DRS XI - Presidente Prudente' FROM dual UNION ALL
  SELECT 'DRS-12', 'DRS XII - Registro' FROM dual UNION ALL
  SELECT 'DRS-13', 'DRS XIII - Ribeirão Preto' FROM dual UNION ALL
  SELECT 'DRS-14', 'DRS XIV - São João da Boa Vista' FROM dual UNION ALL
  SELECT 'DRS-15', 'DRS XV - São José do Rio Preto' FROM dual UNION ALL
  SELECT 'DRS-16', 'DRS XVI - Sorocaba' FROM dual UNION ALL
  SELECT 'DRS-17', 'DRS XVII - Taubaté' FROM dual
) src ON (tgt.COD_DRS = src.COD_DRS)
WHEN NOT MATCHED THEN INSERT (COD_DRS, NOME_DRS) VALUES (src.COD_DRS, src.NOME_DRS);
COMMIT;

-- B. Item 2 deu menos de 4: cria os tipos que faltam.
--    Se der ORA-01400 (coluna obrigatoria), a tabela tem outra coluna NOT NULL: inclua-a no INSERT.
MERGE INTO TB_TIPO_TRATAMENTO tgt
USING (
  SELECT 'Quimioterapia' NOME_TIPO_TRATAMENTO FROM dual UNION ALL
  SELECT 'Radioterapia' FROM dual UNION ALL
  SELECT 'Cirurgia' FROM dual UNION ALL
  SELECT 'Quimioterapia + Radioterapia' FROM dual
) src ON (tgt.NOME_TIPO_TRATAMENTO = src.NOME_TIPO_TRATAMENTO)
WHEN NOT MATCHED THEN INSERT (NOME_TIPO_TRATAMENTO) VALUES (src.NOME_TIPO_TRATAMENTO);
COMMIT;

-- C. Item 5 deu 1 (tentativa anterior): esvazia a staging antes de rodar as 5 partes de novo.
--    Fica comentado de proposito, para nao apagar a staging se o arquivo inteiro for executado.
--    Tire o "--", selecione a linha e rode so ela.
-- TRUNCATE TABLE STG_CASOS_PRAZO60;

-- Item 3 deu menos de 5: os status foram criados na Sprint 3 com faixas e ordem de exibicao.
-- Nao recrie por aqui; confira o script da Sprint 3 que populou TB_STATUS_PRAZO.
