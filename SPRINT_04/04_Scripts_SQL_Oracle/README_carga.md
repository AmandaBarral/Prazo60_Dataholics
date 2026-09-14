# Carga completa do Prazo60 no Oracle (45.416 casos reais)

Roteiro do zero, so com scripts SQL rodados via F5 (Executar Script). Nao
depende mais do assistente grafico de Data Load.

## Ordem de execucao (siga exatamente assim)

### 0. Verificar antes
Rode `00_verificar_antes.sql`. Os scripts de carga supoem que as 17 DRS, os 4
tipos de tratamento e os 5 status de prazo ja existem (Sprint 3). Se algum item
nao bater, rode o bloco de correcao indicado no proprio arquivo. O item 4 diz se
o passo 1 pode ser pulado e o item 5 se o passo 2 pode ser pulado.

### 1. Alterar o schema
Rode `00_alterar_schema_residencia.sql`.
Adiciona a coluna de residencia do paciente em `TB_CASO_PACIENTE`.

### 2. Criar a tabela de staging
Rode `01_criar_staging.sql`.
Cria `STG_CASOS_PRAZO60`, vazia por enquanto.

### 3. Carregar os 45.416 casos na staging
Rode, **em ordem**, os 5 arquivos:
- `01b_carregar_staging_parte1.sql`
- `01b_carregar_staging_parte2.sql`
- `01b_carregar_staging_parte3.sql`
- `01b_carregar_staging_parte4.sql`
- `01b_carregar_staging_parte5.sql`

Cada um tem cerca de 9 mil `INSERT`, pode levar alguns minutos por arquivo.
Aguarde cada um terminar (aparece "Commit concluido" no final) antes de abrir
o proximo.

Depois do 5o arquivo, confirme rodando:
```sql
SELECT COUNT(*) FROM STG_CASOS_PRAZO60;
```
Tem que aparecer `45416`. Se aparecer outro numero, algum dos 5 arquivos nao
terminou de rodar, volte e confira.

### 4. Popular os municipios
Rode `02a_popular_municipios.sql`.
Ja tem o `ALTER SESSION DISABLE PARALLEL DML` no inicio, para evitar o erro
ORA-12839 que apareceu antes.

### 5. Popular as unidades de saude
Rode `02b_popular_unidades.sql`.
Mesma protecao contra o ORA-12839.

Nesse passo e normal ver "0 linhas mescladas" para algumas unidades e "1
linha mesclada" para outras. Isso NAO e erro: "0" significa que aquele
hospital ja existia, "1" significa que foi inserido agora.

### 6. Popular os casos e tratamentos de verdade
Rode `03_popular_fatos.sql`.
Este e o passo que efetivamente cria os 45.416 registros em
`TB_CASO_PACIENTE` e `TB_TRATAMENTO`. So funciona direito se o passo 3
(staging) tiver sido concluido com sucesso.

No final, o proprio script mostra uma contagem por tabela. Esperado:

| Tabela | Quantidade esperada |
|---|---|
| TB_CASO_PACIENTE | ~45.616 (45.416 novos + 200 da demonstracao) |
| TB_TRATAMENTO | ~45.616 |
| TB_UNIDADE_SAUDE | ~247 |
| TB_MUNICIPIO | 646 (645 de SP + 1 sentinela) |

### 6b. Verificar depois
Rode `04_verificar_depois.sql`. Ele compara os totais, o % acima de 60 dias e
os casos por DRS com os numeros publicados no site. O item 3 lista, por motivo,
qualquer caso da staging que nao virou tratamento (esperado: nenhum).

### 7. Testar o Select AI com a base cheia
Repita as mesmas perguntas da Sprint 3 (`SELECT AI RUNSQL ...`). Os numeros
devem mudar para refletir os 45.416 casos, nao mais 200.

## Decisoes ja tomadas com o grupo

- **174 casos fora de SP**: criado um DRS sentinela `DRS-00 - Fora do Estado
  de SP`, para nao perder esses casos.
- **Residencia do paciente**: o schema original so guardava a unidade de
  diagnostico. Foi adicionada a coluna `ID_MUNICIPIO_RESIDENCIA` em
  `TB_CASO_PACIENTE`.
- **Carga via INSERT direto, nao Data Load**: o assistente grafico de
  importacao estava dificil de acompanhar remotamente. Optamos por gerar os
  `INSERT` diretamente, no mesmo formato de script que voces ja rodam com
  sucesso (F5).

## Carga realizada em 13/09/2026 (Prazo60DB, ADMIN)

Resultado conferido com `04_verificar_depois.sql`: 45.416 casos, 61,3% acima de
60 dias, mediana 79 dias e os 18 grupos por DRS (DRS-00 a DRS-17) identicos aos
publicados no site. Nenhum caso ficou de fora e nenhum codigo IBGE repetido.

Correcoes que foram necessarias no banco antes do `03` (ja aplicadas):

1. `TB_STATUS_PRAZO` usa codigos de cor (`Verde`, `Amarelo`, `Laranja`,
   `Vermelho`, `Vencido`); o `03_popular_fatos.sql` foi ajustado para eles.
2. Cadastro da Sprint 3: o municipio ID 5 "São José do Rio Preto" estava com o
   IBGE 354990 (de São José dos Campos), o que duplicava 882 casos no INSERT
   (ORA-00001) e mandaria os 644 residentes de Rio Preto para "Fora do Estado".
   Duas unidades de São José dos Campos tambem estavam ligadas a ele.

```sql
UPDATE TB_MUNICIPIO SET COD_IBGE = '354980'
WHERE ID_MUNICIPIO = 5 AND NOME_MUNICIPIO = 'São José do Rio Preto' AND COD_IBGE = '354990';
UPDATE TB_UNIDADE_SAUDE SET ID_MUNICIPIO = 579 WHERE COD_CNES IN ('0009601', '2748029') AND ID_MUNICIPIO = 5;
COMMIT;
```

Pendente: decidir se os 200 casos da Sprint 3 (`CASO-0001` a `CASO-0200`) continuam no banco.

## Se algo der errado no meio do caminho

Todos os scripts de dimensao (`02a`, `02b`) e de fato (`03`) usam `MERGE` ou
`WHERE NOT EXISTS`, entao rodar de novo nao duplica nada. Se um dos 5
arquivos de INSERT falhar no meio, o mais seguro e conferir quantas linhas
ja entraram (`SELECT COUNT(*) FROM STG_CASOS_PRAZO60`) e rodar de novo so a
partir do arquivo seguinte ao que tinha carregado por ultimo.

## Arquivos deste pacote

| Arquivo | O que faz |
|---|---|
| `00_alterar_schema_residencia.sql` | Adiciona a coluna de residencia do paciente |
| `01_criar_staging.sql` | Cria a tabela temporaria que recebe os casos |
| `01b_carregar_staging_parte1.sql` a `parte5.sql` | Os 45.416 INSERT, em 5 partes |
| `02a_popular_municipios.sql` | Garante os 645 municipios de SP + sentinela |
| `02b_popular_unidades.sql` | Garante as 247 unidades de saude da coorte |
| `03_popular_fatos.sql` | Insere os casos (com residencia) e tratamentos |
| `staging_casos.csv` | Mantido apenas de referencia, nao e mais necessario usar |
