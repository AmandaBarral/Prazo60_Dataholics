-- ============================================================
-- 00. ALTERAR SCHEMA: adicionar municipio de residencia do paciente
-- Rodar ANTES de tudo, uma unica vez.
--
-- TB_CASO_PACIENTE hoje so guarda a unidade de diagnostico (uma unidade
-- de saude, nao um municipio de moradia). Para reproduzir a visao
-- "Residencia do paciente" que ja existe no site, o caso precisa saber
-- em qual municipio o paciente MORA, que pode ser diferente do municipio
-- onde foi diagnosticada ou tratada.
-- ============================================================

ALTER TABLE TB_CASO_PACIENTE ADD ID_MUNICIPIO_RESIDENCIA NUMBER;

ALTER TABLE TB_CASO_PACIENTE ADD CONSTRAINT FK_CASO_MUNICIPIO_RESID
    FOREIGN KEY (ID_MUNICIPIO_RESIDENCIA) REFERENCES TB_MUNICIPIO (ID_MUNICIPIO);

CREATE INDEX IX_CASO_MUNICIPIO_RESID ON TB_CASO_PACIENTE (ID_MUNICIPIO_RESIDENCIA);

COMMENT ON COLUMN TB_CASO_PACIENTE.ID_MUNICIPIO_RESIDENCIA IS
    'Municipio onde o paciente reside, podendo ser diferente do municipio de diagnostico ou tratamento. NULL permitido para compatibilidade com casos ja carregados sem essa informacao (ex.: os 200 casos da demonstracao da Sprint 3).';

COMMIT;
