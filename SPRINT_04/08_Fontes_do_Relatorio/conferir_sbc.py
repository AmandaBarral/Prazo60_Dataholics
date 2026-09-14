import json, sys
from pathlib import Path
sys.path.insert(0, r"C:\Projetos\prazo60-plataforma")
from server.analytics import BaseLocal
b = BaseLocal.carregar(Path(r"C:\Projetos\prazo60-plataforma\server\data"))
r = b.localizador("354870")
def corta(o, prof=0):
    if isinstance(o, dict): return {k: corta(v, prof+1) for k, v in o.items()}
    if isinstance(o, list): return [corta(x, prof+1) for x in o[:3]]
    return o
print(json.dumps(corta(r), ensure_ascii=False, default=str)[:2500])
