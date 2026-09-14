"""
Captura as telas do Prazo60 para a documentacao, usando o Chrome instalado em modo headless
controlado pelo DevTools Protocol (sem instalar navegador extra).

Pre-requisito: servidor local rodando na porta 8061 com SESSION_SECRET igual a SEGREDO abaixo:
    uvicorn server.main:app --port 8061   (com SESSION_SECRET=captura-local-prazo60-somente-dev)

A sessao e assinada localmente com esse segredo de desenvolvimento; nenhuma senha e digitada.
"""

import base64
import json
import subprocess
import tempfile
import time
import urllib.request
from pathlib import Path

from itsdangerous import TimestampSigner
from websockets.sync.client import connect

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
BASE = "http://localhost:8061"
PRODUCAO = "https://prazo60.onrender.com"
SEGREDO = "captura-local-prazo60-somente-dev"
PORTA_CDP = 9333
SAIDA = Path(__file__).resolve().parents[1] / "05_Evidencias" / "capturas"
SAIDA.mkdir(parents=True, exist_ok=True)


class Navegador:
    def __init__(self, url_ws: str):
        self.ws = connect(url_ws, max_size=80_000_000, open_timeout=30)
        self.n = 0

    def call(self, metodo: str, **params):
        self.n += 1
        ident = self.n
        self.ws.send(json.dumps({"id": ident, "method": metodo, "params": params}))
        while True:
            msg = json.loads(self.ws.recv(timeout=120))
            if msg.get("id") == ident:
                if "error" in msg:
                    raise RuntimeError(f"{metodo}: {msg['error']}")
                return msg.get("result", {})

    def js(self, expressao: str):
        r = self.call("Runtime.evaluate", expression=expressao, awaitPromise=True, returnByValue=True)
        return r.get("result", {}).get("value")

    def esperar(self, condicao_js: str, limite: float = 60, pausa: float = 0.5) -> bool:
        fim = time.time() + limite
        while time.time() < fim:
            try:
                if self.js(condicao_js):
                    return True
            except Exception:
                pass
            time.sleep(pausa)
        return False

    def viewport(self, largura: int, altura: int, movel: bool = False):
        self.call("Emulation.setDeviceMetricsOverride", width=largura, height=altura, deviceScaleFactor=1, mobile=movel)

    def abrir(self, url: str):
        self.call("Page.navigate", url=url)
        time.sleep(1)
        self.esperar("document.readyState === 'complete'", 60)
        time.sleep(1)

    def rota(self, nome: str):
        self.js(f"location.hash = '#/{nome}'; window.scrollTo(0, 0); true")
        time.sleep(0.8)
        self.esperar("!document.querySelector('.pagina:not([hidden]).carregando-overlay') && !document.querySelector('.pagina:not([hidden]) .estado-carregando')", 60)
        time.sleep(1.5)

    def rolar_ate(self, seletor: str, margem: int = 80):
        self.js(f"(() => {{ const el = document.querySelector({json.dumps(seletor)}); if (!el) return false; "
                f"window.scrollTo(0, el.getBoundingClientRect().top + window.scrollY - {margem}); return true; }})()")
        time.sleep(1)

    def foto(self, nome: str):
        dados = self.call("Page.captureScreenshot", format="png")["data"]
        caminho = SAIDA / f"{nome}.png"
        caminho.write_bytes(base64.b64decode(dados))
        print("capturado", caminho.name)


def cookie_sessao() -> str:
    conteudo = base64.b64encode(json.dumps({"usuario": "DATAHOLICS", "criada_em": int(time.time())}).encode("utf-8"))
    return TimestampSigner(SEGREDO).sign(conteudo).decode("utf-8")


def main():
    perfil = tempfile.mkdtemp(prefix="prazo60_captura_")
    chrome = subprocess.Popen([
        CHROME, "--headless=new", f"--remote-debugging-port={PORTA_CDP}", "--remote-allow-origins=*",
        f"--user-data-dir={perfil}", "--window-size=1440,900", "--hide-scrollbars", "--no-first-run",
        "--no-default-browser-check", "--disable-extensions", "--lang=pt-BR", "about:blank",
    ])
    try:
        alvo = None
        for _ in range(60):
            try:
                paginas = json.load(urllib.request.urlopen(f"http://127.0.0.1:{PORTA_CDP}/json/list"))
                alvo = next(p for p in paginas if p.get("type") == "page")
                break
            except Exception:
                time.sleep(0.5)
        nav = Navegador(alvo["webSocketDebuggerUrl"])
        nav.call("Page.enable")
        nav.call("Network.enable")
        nav.viewport(1440, 900)

        nav.abrir(f"{PRODUCAO}/login")
        nav.foto("00_producao_login")

        nav.abrir(f"{BASE}/login")
        nav.foto("01_login")

        nav.call("Network.setCookie", name="prazo60_sessao", value=cookie_sessao(), url=BASE, path="/")
        nav.abrir(f"{BASE}/app/#/inicio")
        nav.esperar("document.querySelector('.evidencia-numero') !== null", 60)
        time.sleep(1.5)
        nav.foto("02_inicio")

        nav.rota("executiva")
        nav.foto("03_visao_executiva")
        nav.rolar_ate("#exec-recomendacoes", 160)
        nav.foto("03b_recomendacoes")

        nav.rota("panorama")
        nav.foto("04_panorama_60_dias")

        nav.rota("demanda-oferta")
        nav.foto("05_demanda_oferta")
        nav.rolar_ate("#do-sankey-legenda", 140)
        nav.foto("05b_fluxos_entre_regioes")

        nav.rota("mapa")
        nav.foto("06_mapa")
        nav.js("P60.estado.definir({ drs: '14' }); true")
        time.sleep(3)
        nav.foto("06b_mapa_drs_xiv")
        nav.js("P60.estado.limpar(); true")
        time.sleep(2)

        nav.rota("gargalos")
        nav.foto("07_gargalos")
        nav.rolar_ate("#garg-fatores", 140)
        nav.foto("07b_fatores_relacionados")
        nav.rolar_ate("#garg-recomendacoes", 160)
        nav.foto("07c_motor_apoio_decisao")

        nav.rota("encaminhar")
        nav.js("document.getElementById('enc-exemplo').click(); true")
        nav.esperar("document.querySelectorAll('.unidade').length > 0", 60)
        time.sleep(1.5)
        nav.foto("08_para_onde_encaminhar")
        nav.rolar_ate(".unidades-lista", 160)
        nav.foto("08b_unidades_compativeis")

        nav.rota("simulacao")
        nav.js("const s = document.getElementById('sim-municipio'); s.value = '354870'; s.dispatchEvent(new Event('change')); true")
        nav.esperar("!document.getElementById('sim-ir-2').disabled", 60)
        time.sleep(1)
        nav.foto("09_simulacao_etapa1")
        nav.js("document.getElementById('sim-ir-2').click(); true")
        time.sleep(1.5)
        nav.foto("09b_simulacao_etapa2")
        nav.js("document.getElementById('sim-ir-3').click(); document.getElementById('sim-executar').click(); true")
        nav.esperar("document.querySelector('.resultado-topo') !== null", 90)
        time.sleep(2)
        nav.rolar_ate("#sim-stepper", 100)
        nav.foto("09c_simulacao_resultado")
        nav.rolar_ate("#graf-sim-distribuicao", 160)
        nav.foto("09d_simulacao_carga_unidades")

        nav.rota("powerbi")
        time.sleep(6)
        nav.foto("10_power_bi")

        nav.rota("ia")
        perguntas = [
            "Qual região (DRS) mais piorou entre 2024 e 2025?",
            "Onde existe maior pressão entre demanda e oferta?",
            "Quais os 10 municípios com maior percentual acima de 60 dias?",
        ]
        for i, pergunta in enumerate(perguntas, start=1):
            nav.js(f"document.getElementById('ia-pergunta').value = {json.dumps(pergunta)}; document.getElementById('ia-form').requestSubmit(); true")
            nav.esperar(f"(() => {{ const m = document.querySelectorAll('.chat-resposta'); return m.length >= {i} && !m[{i - 1}].textContent.includes('Consultando'); }})()", 120)
            time.sleep(4)
        nav.js("document.getElementById('ia-historico').scrollTop = 0; true")
        nav.rolar_ate(".chat", 120)
        nav.foto("11_prazo60_ai")
        nav.js("const h = document.getElementById('ia-historico'); h.scrollTop = h.scrollHeight; true")
        time.sleep(1)
        nav.foto("11b_prazo60_ai_ranking")

        nav.rota("dados")
        nav.foto("12_dados_fontes")
        nav.js("document.querySelector('#dados-abas [data-aba=\"pipeline\"]').click(); true")
        time.sleep(1.5)
        nav.foto("12b_pipeline_arquitetura")
        nav.js("document.querySelector('#dados-abas [data-aba=\"qualidade\"]').click(); true")
        time.sleep(1.5)
        nav.foto("12c_qualidade_dados")
        nav.js("document.querySelector('#dados-abas [data-aba=\"limitacoes\"]').click(); true")
        time.sleep(1.5)
        nav.foto("12d_limitacoes")

        nav.rota("sobre")
        nav.foto("13_sobre")

        nav.viewport(390, 844, movel=True)
        nav.rota("executiva")
        time.sleep(2)
        nav.foto("14_celular_visao_executiva")
    finally:
        chrome.terminate()


if __name__ == "__main__":
    main()
