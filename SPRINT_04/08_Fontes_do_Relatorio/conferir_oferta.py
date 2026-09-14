import sys
from pathlib import Path
sys.path.insert(0, r"C:\Projetos\prazo60-plataforma")
from server.analytics import BaseLocal, Filtros
b = BaseLocal.carregar(Path(r"C:\Projetos\prazo60-plataforma\server\data"))
p = b.painel(Filtros())
tot_c = tot_e = 0
for d in p["por_drs"]:
    print(d["drs"], d.get("estabelecimentos_cacon_unacon"), {k: v for k, v in d.items() if "casos" in k or "pressao" in k or "oferta" in k})
for a in p["alertas"]: print("alerta", a["drs"], a["classificacao"])
for m in p["alertas_municipios"][:5]: print("mun", m["nome"], m["pct_fora_recente"], m["casos_ano_recente"], m["classificacao"])
