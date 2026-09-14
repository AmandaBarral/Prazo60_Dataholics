# 12 · Limitações e próximos passos

## Limitações

1. **Defasagem dos dados públicos:** anos recentes ainda recebem registros; 2026 é parcial.
2. **Viés de casos fechados:** a base só contém pacientes que já iniciaram tratamento. Esperas longas em curso não
   aparecem, o que tende a subestimar o atraso nos meses mais recentes.
3. **Sem ocupação em tempo real:** localização de uma unidade não significa existência de vaga.
4. **Simulações são hipotéticas:** dependem de premissas (utilização de base e parte da espera sensível à fila).
5. **Oferta sem denominador populacional:** pressão assistencial compara volumes absolutos.
6. **Distância em linha reta** entre sedes municipais; não é rota nem tempo de viagem.
7. **Correlação não é causalidade** nos cruzamentos de demanda, oferta e prazo.
8. **Nomes de unidades:** só 20 de 114 CNES tratantes com nome e habilitação confirmados.
9. **IA:** o modelo pode interpretar a pergunta de forma diferente; o SQL é sempre exibido para conferência. Plano
   gratuito do Gemini tem limites de uso e instabilidades.
10. **Infraestrutura gratuita:** Render hiberna; Oracle Always Free para após 7 dias sem uso.
11. **200 casos da Sprint 3** permanecem nas tabelas (fora das views da IA).
12. **Ferramenta de apoio à decisão:** não substitui a regulação oficial (CROSS-SP, DRS) nem decisão clínica.

## Próximos passos

| Prioridade | Ação |
|---|---|
| Alta | Remover ou marcar os 200 casos da Sprint 3; trocar senha do site após a apresentação |
| Alta | Integrar API CNES para nomes, endereços e habilitações atualizados |
| Média | Provedor de dados Oracle para os painéis (mesmo contrato de `BaseLocal`) |
| Média | Parametrizar os anos da view `VW_P60_DRS` (hoje 2024/2025) |
| Média | Denominador populacional (IBGE) para taxas de cobertura |
| Média | Retornar ao OCI Generative AI quando houver cota, mantendo as mesmas views |
| Futura | Integração com regulação (CROSS-SP) para disponibilidade real |
| Futura | Acompanhamento de casos em aberto (pseudonimizados, com controle de acesso por perfil) |
| Futura | SIH/SUS e RHC/INCA para estadiamento, procedimentos e desfechos |
