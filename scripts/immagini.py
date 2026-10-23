#!/usr/bin/env python3
"""Scarica da Wikimedia Commons le foto indicate nel campo `immagini` delle
schede di piante e funghi, ne verifica la licenza e scrive
app/assets/immagini/crediti.json con autore, licenza e link di ogni foto.
Serve la rete: gira su GitHub Actions."""
import html
import json
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
PIANTE = ROOT / "dati" / "piante"
FUNGHI = ROOT / "dati" / "funghi"
CARTELLA = ROOT / "app" / "assets" / "immagini"
CREDITI = CARTELLA / "crediti.json"
API = "https://commons.wikimedia.org/w/api.php"
AGENTE = "PiantalAPP/0.1 (https://github.com/pxcalleg/piantalapp)"
LARGHEZZA = 900
LICENZE_LIBERE = re.compile(r"^(CC0|CC BY(-SA)? \d(\.\d)?|Public domain)$", re.I)


def scarica(url):
    req = urllib.request.Request(url, headers={"User-Agent": AGENTE})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def info(nome):
    q = urllib.parse.urlencode({
        "action": "query", "format": "json", "titles": f"File:{nome}",
        "prop": "imageinfo", "iiprop": "url|extmetadata", "iiurlwidth": LARGHEZZA,
    })
    pagine = json.loads(scarica(f"{API}?{q}"))["query"]["pages"]
    pagina = next(iter(pagine.values()))
    if "imageinfo" not in pagina:
        raise ValueError(f"file non trovato su Commons: {nome}")
    ii = pagina["imageinfo"][0]
    meta = ii.get("extmetadata", {})

    def campo(k):
        testo = meta.get(k, {}).get("value", "")
        return html.unescape(re.sub(r"<[^>]+>", "", testo)).strip()

    autore = campo("Artist") or campo("Credit") or "Autore sconosciuto"
    # Commons a volte scrive "No machine-readable author provided. X assumed
    # (based on copyright claims)." quando l'autore è dedotto dal caricatore.
    dedotto = re.match(r"No machine-readable author provided\. (.+?) assumed", autore)
    if dedotto:
        autore = dedotto.group(1)
    return {
        "commons": nome,
        "autore": autore,
        "licenza": campo("LicenseShortName"),
        "url_licenza": campo("LicenseUrl"),
        "pagina": ii["descriptionurl"],
        "anteprima": ii.get("thumburl") or ii["url"],
    }


def schede():
    return sorted(PIANTE.glob("*.yaml")) + sorted(FUNGHI.glob("*.yaml"))


def verifica():
    """Controlla solo che ogni foto esista su Commons e abbia licenza libera,
    senza scaricare nulla: gira sulle pull request."""
    errori = []
    for file in schede():
        scheda = yaml.safe_load(file.read_text(encoding="utf-8"))
        for imm in scheda.get("immagini", []):
            try:
                dati = info(imm["commons"])
            except Exception as e:
                errori.append(f"{file.name}: {e}")
                continue
            if not LICENZE_LIBERE.match(dati["licenza"]):
                errori.append(f"{file.name}: licenza non libera '{dati['licenza']}' per {imm['commons']}")
                continue
            print(f"✓ {file.name}: {imm['commons']} ({dati['licenza']}, {dati['autore']})")
    if errori:
        print("\n".join(errori), file=sys.stderr)
        sys.exit(1)


def main():
    if "--verifica" in sys.argv:
        return verifica()
    CARTELLA.mkdir(parents=True, exist_ok=True)
    precedenti = {
        c["file"]: c["commons"]
        for lista in (json.loads(CREDITI.read_text(encoding="utf-8")) if CREDITI.exists() else {}).values()
        for c in lista
    }
    crediti, errori, usati = {}, [], set()
    for file in schede():
        scheda = yaml.safe_load(file.read_text(encoding="utf-8"))
        for i, imm in enumerate(scheda.get("immagini", [])):
            nome = imm["commons"]
            try:
                dati = info(nome)
            except Exception as e:
                errori.append(f"{file.name}: {e}")
                continue
            if not LICENZE_LIBERE.match(dati["licenza"]):
                errori.append(f"{file.name}: licenza non libera '{dati['licenza']}' per {nome}")
                continue
            locale = f"{scheda['id']}-{i + 1}.jpg"
            percorso = CARTELLA / locale
            # Riscarica solo se manca o se la scheda indica un'altra foto.
            if not percorso.exists() or precedenti.get(locale) != nome:
                percorso.write_bytes(scarica(dati["anteprima"]))
            usati.add(locale)
            crediti.setdefault(scheda["id"], []).append({
                "file": locale,
                **{k: dati[k] for k in ("commons", "autore", "licenza", "url_licenza", "pagina", "anteprima")},
                **({"didascalia": imm["didascalia"]} if "didascalia" in imm else {}),
            })
            print(f"✓ {locale}: {dati['licenza']}, {dati['autore']}")
    for f in CARTELLA.glob("*.jpg"):
        if f.name not in usati:
            f.unlink()
    CREDITI.write_text(json.dumps(crediti, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    if errori:
        print("\n".join(errori), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
