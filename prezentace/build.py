#!/usr/bin/env python3
"""Zabalí index.html + lib/ do jednoho souboru hackni-chatbota.html (funguje bez složky lib).
Použití:  python3 build.py"""
import base64, pathlib, re
R = pathlib.Path(__file__).parent
t = (R/"index.html").read_text(encoding="utf-8")
t = re.sub(r'url\((lib/fonts/[^)]+\.woff2)\)', lambda m: "url(data:font/woff2;base64," + base64.b64encode((R/m.group(1)).read_bytes()).decode() + ")", t)
t = t.replace('<link rel="stylesheet" href="lib/reveal.css">', "<style>" + (R/"lib/reveal.css").read_text(encoding="utf-8") + "</style>")
for f in ["reveal.js", "notes.js", "qrcode.js"]:
    js = (R/"lib"/f).read_text(encoding="utf-8").replace("</script", "<\\/script")
    t = t.replace(f'<script src="lib/{f}"></script>', "<script>" + js + "</script>")
(R/"hackni-chatbota.html").write_text(t, encoding="utf-8")
print("Hotovo: hackni-chatbota.html")
