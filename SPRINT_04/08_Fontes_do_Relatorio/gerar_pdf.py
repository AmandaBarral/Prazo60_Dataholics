"""
Gera 01_Relatorio_TCC_Prazo60.pdf a partir de capa.html e tcc.html usando o Chrome instalado (headless).

    python gerar_pdf.py

1. imprime a capa (sem rodape);
2. imprime o corpo, descobre em que pagina cada secao caiu (marcadores invisiveis §sec-...§);
3. preenche o sumario com essas paginas e imprime de novo;
4. junta capa + corpo e grava os metadados.
Para editar o texto, altere tcc.html e rode novamente.
"""

import base64
import io
import json
import re
import subprocess
import tempfile
import time
import urllib.request
from pathlib import Path

from pypdf import PdfReader, PdfWriter
from websockets.sync.client import connect

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
FONTE = Path(__file__).resolve().parent
SAIDA = FONTE.parent / "01_Relatorio_TCC_Prazo60.pdf"
PORTA = 9334
RODAPE = ('<div style="width:100%;font-family:Arial,sans-serif;font-size:8px;color:#6E6269;'
          'padding:0 20mm 0 30mm;display:flex;justify-content:space-between;">'
          '<span>Prazo60 · Challenge FIAP · Grupo Dataholics · 2026</span><span class="pageNumber"></span></div>')


class Navegador:
    def __init__(self, url_ws):
        self.ws = connect(url_ws, max_size=200_000_000, open_timeout=30)
        self.n = 0

    def call(self, metodo, **params):
        self.n += 1
        ident = self.n
        self.ws.send(json.dumps({"id": ident, "method": metodo, "params": params}))
        while True:
            msg = json.loads(self.ws.recv(timeout=300))
            if msg.get("id") == ident:
                if "error" in msg:
                    raise RuntimeError(f"{metodo}: {msg['error']}")
                return msg.get("result", {})

    def js(self, expressao):
        r = self.call("Runtime.evaluate", expression=expressao, awaitPromise=True, returnByValue=True)
        return r.get("result", {}).get("value")

    def abrir(self, caminho: Path):
        self.call("Page.navigate", url=caminho.as_uri())
        for _ in range(240):
            pronto = self.js("document.readyState === 'complete' && [...document.images].every(i => i.complete)")
            if pronto:
                break
            time.sleep(0.25)
        self.js("document.fonts.ready.then(() => true)")
        time.sleep(1)

    def imprimir(self, com_rodape: bool) -> bytes:
        r = self.call("Page.printToPDF", printBackground=True, preferCSSPageSize=True,
                      displayHeaderFooter=com_rodape, headerTemplate="<span></span>",
                      footerTemplate=RODAPE if com_rodape else "<span></span>")
        return base64.b64decode(r["data"])


def paginas_das_secoes(pdf: bytes) -> dict:
    encontradas = {}
    for i, pagina in enumerate(PdfReader(io.BytesIO(pdf)).pages, start=1):
        texto = pagina.extract_text() or ""
        # titulos de capitulo usam text-transform: uppercase, entao o marcador pode sair em maiusculas
        for ref in re.findall(r"§(sec-[a-z0-9\-]+)§", texto, flags=re.IGNORECASE):
            encontradas.setdefault(ref.lower(), i)
    return encontradas


def main():
    perfil = tempfile.mkdtemp(prefix="prazo60_pdf_")
    chrome = subprocess.Popen([CHROME, "--headless=new", f"--remote-debugging-port={PORTA}", "--remote-allow-origins=*",
                               f"--user-data-dir={perfil}", "--no-first-run", "--disable-extensions",
                               "--allow-file-access-from-files", "about:blank"])
    try:
        alvo = None
        for _ in range(60):
            try:
                alvo = next(p for p in json.load(urllib.request.urlopen(f"http://127.0.0.1:{PORTA}/json/list")) if p.get("type") == "page")
                break
            except Exception:
                time.sleep(0.5)
        nav = Navegador(alvo["webSocketDebuggerUrl"])
        nav.call("Page.enable")

        nav.abrir(FONTE / "capa.html")
        capa = nav.imprimir(False)

        nav.abrir(FONTE / "tcc.html")
        primeira = nav.imprimir(True)
        paginas = paginas_das_secoes(primeira)
        print("secoes localizadas:", len(paginas))
        nav.js(f"window.preencherSumario({json.dumps(paginas)})")
        corpo = nav.imprimir(True)
        conferencia = paginas_das_secoes(corpo)
        if conferencia != paginas:
            print("aviso: paginacao mudou apos preencher o sumario; repetindo")
            nav.js(f"window.preencherSumario({json.dumps(conferencia)})")
            corpo = nav.imprimir(True)

        escritor = PdfWriter()
        for origem in (capa, corpo):
            for pagina in PdfReader(io.BytesIO(origem)).pages:
                escritor.add_page(pagina)
        escritor.add_metadata({
            "/Title": "Prazo60 – Plataforma de inteligência em saúde pública",
            "/Author": "Grupo Dataholics (Amanda, Eduardo, Gabriela, Julia, Livia)",
            "/Subject": "Challenge FIAP (banca Oracle) · monitoramento do prazo legal de 60 dias no tratamento do câncer de mama no SUS-SP",
            "/Keywords": "câncer de mama; Lei 12.732/2012; saúde pública; apoio à decisão; Select AI",
        })
        with open(SAIDA, "wb") as arquivo:
            escritor.write(arquivo)
        print(f"gerado {SAIDA} com {len(escritor.pages)} paginas")
        faltando = [ref for ref in re.findall(r'data-ref="([^"]+)"', (FONTE / "tcc.html").read_text(encoding="utf-8")) if ref not in paginas]
        print("secoes do sumario sem pagina:", faltando or "nenhuma")
    finally:
        chrome.terminate()


if __name__ == "__main__":
    main()
