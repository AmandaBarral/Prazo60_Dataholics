-- ============================================================
-- 01. TABELA DE STAGING (temporaria, sem FK)
-- Recebe o CSV bruto via Data Load (SQL Developer / Database Actions),
-- antes de ser distribuida entre TB_CASO_PACIENTE e TB_TRATAMENTO.
-- ============================================================

CREATE TABLE STG_CASOS_PRAZO60 (
    COD_CASO                VARCHAR2(20),
    DATA_NASCIMENTO         VARCHAR2(10),   -- formato DD/MM/YYYY, convertido no passo 3
    ESTAGIO_TUMOR           VARCHAR2(2),
    DATA_DIAGNOSTICO        VARCHAR2(10),
    CNES_DIAGNOSTICO        VARCHAR2(15),
    MUN_DIAGNOSTICO_IBGE    VARCHAR2(7),
    MUN_RESIDENCIA_IBGE     VARCHAR2(7),
    NOME_TIPO_TRATAMENTO    VARCHAR2(30),
    CNES_TRATAMENTO         VARCHAR2(15),
    MUN_TRATAMENTO_IBGE     VARCHAR2(7),
    DATA_INICIO_TRATAMENTO  VARCHAR2(10),
    DIAS_ESPERA             NUMBER
);

-- Depois de criar esta tabela:
-- 1. Va em Database Actions (ou SQL Developer) > Data Load
-- 2. Selecione o arquivo staging_casos.csv
-- 3. Escolha "Existing Table" e aponte para STG_CASOS_PRAZO60
-- 4. Delimitador: ponto e virgula (;)
-- 5. Confirme que a primeira linha e cabecalho (Header)
SELECT COUNT(*) FROM STG_CASOS_PRAZO60;