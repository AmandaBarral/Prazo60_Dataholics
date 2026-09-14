    -- ============================================================
-- 03. POPULAR TB_CASO_PACIENTE E TB_TRATAMENTO a partir do staging
-- Rodar depois de 01 (staging + Data Load) e 02a/02b (dimensoes).
-- ============================================================

-- Desliga o paralelismo automatico do Autonomous DB para esta sessao.
-- Sem isso, o filtro de deduplicacao (MIN(ROWID) por COD_CASO) pode ser
-- avaliado de forma inconsistente entre processos paralelos, causando
-- ORA-12801 / ORA-00001 mesmo com a logica de deduplicacao correta.
ALTER SESSION DISABLE PARALLEL DML;
ALTER SESSION DISABLE PARALLEL QUERY;

-- --- 3.1: TB_CASO_PACIENTE ---
-- Um caso por linha de staging. ID_UNIDADE_DIAGNOSTICO resolvido pelo CNES.
-- ID_MUNICIPIO_RESIDENCIA resolvido pelo codigo IBGE; quando o paciente reside
-- fora de SP (nao existe na tabela de municipios), cai no sentinela 'Fora do
-- Estado de SP' criado no passo 00/02a.
INSERT INTO TB_CASO_PACIENTE (
    COD_CASO, DATA_NASCIMENTO, ESTAGIO_TUMOR, DATA_DIAGNOSTICO,
    ID_UNIDADE_DIAGNOSTICO, ID_MUNICIPIO_RESIDENCIA
)
SELECT
    s.COD_CASO,
    TO_DATE(s.DATA_NASCIMENTO, 'DD/MM/YYYY'),
    NULLIF(s.ESTAGIO_TUMOR, ''),
    TO_DATE(s.DATA_DIAGNOSTICO, 'DD/MM/YYYY'),
    u.ID_UNIDADE,
    COALESCE(mr.ID_MUNICIPIO, (SELECT ID_MUNICIPIO FROM TB_MUNICIPIO WHERE NOME_MUNICIPIO = 'Fora do Estado de SP'))
FROM STG_CASOS_PRAZO60 s
JOIN TB_UNIDADE_SAUDE u ON u.COD_CNES = s.CNES_DIAGNOSTICO
LEFT JOIN TB_MUNICIPIO mr ON mr.COD_IBGE = s.MUN_RESIDENCIA_IBGE
WHERE s.ROWID = (SELECT MIN(s2.ROWID) FROM STG_CASOS_PRAZO60 s2 WHERE s2.COD_CASO = s.COD_CASO)
AND NOT EXISTS (
    SELECT 1 FROM TB_CASO_PACIENTE tc WHERE tc.COD_CASO = s.COD_CASO
);

COMMIT;

-- --- 3.2: TB_TRATAMENTO ---
-- ID_STATUS_PRAZO calculado pelas mesmas faixas que voces ja definiram em TB_STATUS_PRAZO.
-- Os codigos gravados no banco sao cores (conferido com SELECT * FROM TB_STATUS_PRAZO):
--   Verde ate 30 dias | Amarelo 31-45 | Laranja 46-59 | Vermelho exatamente 60 | Vencido 61+
INSERT INTO TB_TRATAMENTO (
    ID_CASO, ID_TIPO_TRATAMENTO, ID_UNIDADE_TRATAMENTO,
    DATA_INICIO_TRATAMENTO, DIAS_ESPERA, ID_STATUS_PRAZO
)
SELECT
    c.ID_CASO,
    tt.ID_TIPO_TRATAMENTO,
    ut.ID_UNIDADE,
    TO_DATE(s.DATA_INICIO_TRATAMENTO, 'DD/MM/YYYY'),
    s.DIAS_ESPERA,
    sp.ID_STATUS_PRAZO
FROM STG_CASOS_PRAZO60 s
JOIN TB_CASO_PACIENTE c   ON c.COD_CASO = s.COD_CASO
JOIN TB_TIPO_TRATAMENTO tt ON tt.NOME_TIPO_TRATAMENTO = s.NOME_TIPO_TRATAMENTO
JOIN TB_UNIDADE_SAUDE ut  ON ut.COD_CNES = s.CNES_TRATAMENTO
JOIN TB_STATUS_PRAZO sp ON sp.COD_STATUS = (
    CASE
        WHEN s.DIAS_ESPERA <= 30 THEN 'Verde'
        WHEN s.DIAS_ESPERA BETWEEN 31 AND 45 THEN 'Amarelo'
        WHEN s.DIAS_ESPERA BETWEEN 46 AND 59 THEN 'Laranja'
        WHEN s.DIAS_ESPERA = 60 THEN 'Vermelho'
        ELSE 'Vencido'
    END
)
WHERE s.ROWID = (SELECT MIN(s2.ROWID) FROM STG_CASOS_PRAZO60 s2 WHERE s2.COD_CASO = s.COD_CASO)
AND NOT EXISTS (
    SELECT 1 FROM TB_TRATAMENTO t2 WHERE t2.ID_CASO = c.ID_CASO
);

COMMIT;

-- --- 3.3: Conferencia ---
SELECT 'TB_CASO_PACIENTE' AS TABELA, COUNT(*) AS QTD FROM TB_CASO_PACIENTE
UNION ALL
SELECT 'TB_TRATAMENTO', COUNT(*) FROM TB_TRATAMENTO
UNION ALL
SELECT 'TB_UNIDADE_SAUDE', COUNT(*) FROM TB_UNIDADE_SAUDE
UNION ALL
SELECT 'TB_MUNICIPIO', COUNT(*) FROM TB_MUNICIPIO;

-- Esperado apos a carga completa: TB_CASO_PACIENTE = 45.416 (mais os 200 de demonstracao,
-- se voces nao apagaram), TB_UNIDADE_SAUDE = 247 novas + as ja existentes, TB_MUNICIPIO = 646
-- (645 de SP + 1 sentinela Fora do Estado de SP).

-- --- 3.4 (opcional): apagar a tabela de staging depois de conferir ---
-- DROP TABLE STG_CASOS_PRAZO60 PURGE;
