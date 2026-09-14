import json, statistics, sys
from collections import defaultdict
from pathlib import Path
sys.path.insert(0, r"C:\Projetos\prazo60-plataforma")
from server.analytics import BaseLocal, Filtros
b = BaseLocal.carregar(Path(r"C:\Projetos\prazo60-plataforma\server\data"))
cs = b.casos; n = len(cs)
print("N", n, "acima", sum(c.dias > 60 for c in cs))
for a, z in [(0,30),(31,45),(46,60),(61,90),(91,120),(121,10**6)]:
    k = sum(a <= c.dias <= z for c in cs); print("faixa", a, z, k, round(100*k/n,1))
pt = defaultdict(list)
for c in cs: pt[c.tipo].append(c.dias)
def pct(d): return round(100*sum(x>60 for x in d)/len(d),1) if d else None
for t, d in sorted(pt.items()): print("tipo", t, len(d), pct(d), statistics.median(d))
pd_ = defaultdict(list); pda = defaultdict(list)
for c in cs: pd_[c.drs_res].append(c.dias); pda[(c.drs_res,c.ano)].append(c.dias)
for d in sorted(pd_):
    p24, p25 = pct(pda[(d,2024)]), pct(pda[(d,2025)])
    print("drs", d, len(pd_[d]), pct(pd_[d]), p24, p25, round(p25-p24,1) if p24 is not None and p25 is not None else None, "c2025", len(pda[(d,2025)]))
for ano in (2024, 2025):
    d = [c.dias for c in cs if c.ano == ano]; print("ano", ano, len(d), pct(d), statistics.median(d))
print("migracao", sum(c.drs_res != c.drs_trat for c in cs))
p = b.painel(Filtros())
def est(o, pre="", prof=0):
    if prof > 2: return
    if isinstance(o, dict):
        for k, v in o.items():
            r = v if not isinstance(v,(dict,list)) else type(v).__name__ + f"[{len(v)}]"
            print(pre + k, "=", str(r)[:120]); est(v, pre + "  ", prof + 1)
    elif isinstance(o, list) and o:
        print(pre + "[0] =", json.dumps(o[0], ensure_ascii=False, default=str)[:300])
est(p)
