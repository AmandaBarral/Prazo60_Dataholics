-- ============================================================
-- 04. VERIFICAR DEPOIS DA CARGA (rodar como ADMIN)
-- Os valores esperados sao os mesmos publicados no site Prazo60
-- (conferidos pelo ETL em prazo60-plataforma/etl/relatorio_validacao.md).
-- ============================================================

-- 1. Totais. Esperado: STG 45.416 | casos e tratamentos 45.416 (+200 se os casos da Sprint 3 continuam)
SELECT 'STG_CASOS_PRAZO60' AS tabela, COUNT(*) AS qtd FROM STG_CASOS_PRAZO60
UNION ALL SELECT 'TB_CASO_PACIENTE', COUNT(*) FROM TB_CASO_PACIENTE
UNION ALL SELECT 'TB_TRATAMENTO', COUNT(*) FROM TB_TRATAMENTO
UNION ALL SELECT 'TB_MUNICIPIO', COUNT(*) FROM TB_MUNICIPIO
UNION ALL SELECT 'TB_UNIDADE_SAUDE', COUNT(*) FROM TB_UNIDADE_SAUDE;

-- 2. Municipio com codigo IBGE repetido (grafia da Sprint 3 diferente da oficial).
--    Esperado: nenhuma linha. Se aparecer, ver bloco de correcao no fim.
SELECT COD_IBGE, COUNT(*) AS registros, LISTAGG(NOME_MUNICIPIO, ' | ') AS nomes
FROM TB_MUNICIPIO GROUP BY COD_IBGE HAVING COUNT(*) > 1;

-- 3. Casos da staging que NAO viraram tratamento, por motivo. Esperado: nenhuma linha.
SELECT motivo, COUNT(*) AS casos FROM (
  SELECT CASE
           WHEN ud.ID_UNIDADE IS NULL THEN 'CNES de diagnostico nao cadastrado'
           WHEN c.ID_CASO IS NULL THEN 'Caso nao inserido em TB_CASO_PACIENTE'
           WHEN tt.ID_TIPO_TRATAMENTO IS NULL THEN 'Tipo de tratamento nao cadastrado: ' || s.NOME_TIPO_TRATAMENTO
           WHEN ut.ID_UNIDADE IS NULL THEN 'CNES de tratamento nao cadastrado'
           ELSE 'Outro (conferir TB_STATUS_PRAZO)'
         END AS motivo
  FROM STG_CASOS_PRAZO60 s
  LEFT JOIN TB_CASO_PACIENTE c    ON c.COD_CASO = s.COD_CASO
  LEFT JOIN TB_TRATAMENTO t       ON t.ID_CASO = c.ID_CASO
  LEFT JOIN TB_UNIDADE_SAUDE ud   ON ud.COD_CNES = s.CNES_DIAGNOSTICO
  LEFT JOIN TB_UNIDADE_SAUDE ut   ON ut.COD_CNES = s.CNES_TRATAMENTO
  LEFT JOIN TB_TIPO_TRATAMENTO tt ON tt.NOME_TIPO_TRATAMENTO = s.NOME_TIPO_TRATAMENTO
  WHERE t.ID_CASO IS NULL
) GROUP BY motivo;

-- 4. Indicador geral (so os casos desta carga). Esperado: 45416 | 61,3 | 79
SELECT COUNT(*) AS casos,
       ROUND(100 * AVG(CASE WHEN t.DIAS_ESPERA > 60 THEN 1 ELSE 0 END), 1) AS pct_fora_60,
       MEDIAN(t.DIAS_ESPERA) AS mediana_dias
FROM TB_TRATAMENTO t
JOIN TB_CASO_PACIENTE c ON c.ID_CASO = t.ID_CASO
WHERE c.COD_CASO IN (SELECT COD_CASO FROM STG_CASOS_PRAZO60);

-- 5. Casos por DRS de residencia. Esperado:
--    DRS-00 1778 (Fora do Estado de SP)
--    DRS-01 16568 | 02 993 | 03 924 | 04 1808 | 05 857 | 06 1999 | 07 4598 | 08 797 | 09 1635
--    DRS-10 1617  | 11 999 | 12 367 | 13 1796 | 14 971 | 15 2309 | 16 2460 | 17 2940
--    DRS-00 muito maior que 1778 = municipios ou DRS faltando antes do 02a.
SELECT d.COD_DRS, COUNT(*) AS casos,
       ROUND(100 * AVG(CASE WHEN t.DIAS_ESPERA > 60 THEN 1 ELSE 0 END), 1) AS pct_fora_60
FROM TB_TRATAMENTO t
JOIN TB_CASO_PACIENTE c ON c.ID_CASO = t.ID_CASO
JOIN TB_MUNICIPIO m     ON m.ID_MUNICIPIO = c.ID_MUNICIPIO_RESIDENCIA
JOIN TB_DRS d           ON d.ID_DRS = m.ID_DRS
WHERE c.COD_CASO IN (SELECT COD_CASO FROM STG_CASOS_PRAZO60)
GROUP BY d.COD_DRS
ORDER BY d.COD_DRS;


-- ============================================================
-- CORRECAO do item 2 (so se apareceu codigo IBGE repetido).
-- Rodar LOGO APOS o 02a e ANTES do 02b e do 03.
-- Mantem o registro antigo (Sprint 3, ja referenciado por unidades e casos),
-- troca o nome dele pelo oficial e apaga o duplicado recem-criado pelo 02a.
-- Comentado de proposito: tire os "--" das linhas abaixo, selecione o bloco e rode so ele.
-- ============================================================
-- BEGIN
--   FOR d IN (SELECT COD_IBGE, MIN(ID_MUNICIPIO) AS id_antigo, MAX(ID_MUNICIPIO) AS id_novo
--             FROM TB_MUNICIPIO GROUP BY COD_IBGE HAVING COUNT(*) = 2) LOOP
--     DECLARE
--       v_nome TB_MUNICIPIO.NOME_MUNICIPIO%TYPE;
--     BEGIN
--       SELECT NOME_MUNICIPIO INTO v_nome FROM TB_MUNICIPIO WHERE ID_MUNICIPIO = d.id_novo;
--       DELETE FROM TB_MUNICIPIO WHERE ID_MUNICIPIO = d.id_novo;
--       UPDATE TB_MUNICIPIO SET NOME_MUNICIPIO = v_nome WHERE ID_MUNICIPIO = d.id_antigo;
--     END;
--   END LOOP;
--   COMMIT;
-- END;
-- /
