#!/usr/bin/env python3
"""Valida le schede in dati/piante/ contro lo schema e, con --build,
genera il pacchetto JSON letto dall'app (per l'app: --out app/assets/piante.json)."""
import argparse, json, sys
from pathlib import Path

import yaml
from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parent.parent
SCHEMA = ROOT / "schema" / "pianta.schema.json"
PIANTE = ROOT / "dati" / "piante"
DIST = ROOT / "dist" / "piante.json"
CREDITI = ROOT / "app" / "assets" / "immagini" / "crediti.json"


def controlli_extra(scheda, file):
    errori = []
    if scheda.get("id") != file.stem:
        errori.append(f"id '{scheda.get('id')}' diverso dal nome file '{file.stem}'")
    for campo in ("primavera_estate", "autunno_inverno"):
        r = scheda.get("annaffiatura", {}).get(campo, {})
        if r and r["min"] > r["max"]:
            errori.append(f"annaffiatura.{campo}: min > max")
    t = scheda.get("temperatura", {})
    if t and not (t["min_c"] <= t["ideale_min_c"] <= t["ideale_max_c"]):
        errori.append("temperatura: serve min_c <= ideale_min_c <= ideale_max_c")
    luce = scheda.get("luce", {})
    if luce.get("ideale") in luce.get("tollera", []):
        errori.append("luce: il livello ideale non va ripetuto in 'tollera'")
    elencati = set(scheda.get("propagazione", []))
    spiegati = [g["metodo"] for g in scheda.get("come_si_propaga", [])]
    if len(spiegati) != len(set(spiegati)):
        errori.append("come_si_propaga: ogni metodo va spiegato una volta sola")
    if set(spiegati) != elencati:
        errori.append("come_si_propaga: serve una spiegazione per ogni metodo di 'propagazione', e solo per quelli")
    return errori


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--build", action="store_true", help="genera il pacchetto JSON delle schede")
    ap.add_argument("--out", type=Path, default=DIST, help="dove scrivere il JSON (default: dist/piante.json)")
    args = ap.parse_args()

    validator = Draft202012Validator(json.loads(SCHEMA.read_text(encoding="utf-8")))
    schede, falliti = [], 0
    for file in sorted(PIANTE.glob("*.yaml")):
        scheda = yaml.safe_load(file.read_text(encoding="utf-8"))
        errori = [f"{'/'.join(map(str, e.path)) or '(radice)'}: {e.message}"
                  for e in validator.iter_errors(scheda)]
        if not errori:
            errori = controlli_extra(scheda, file)
        if errori:
            falliti += 1
            print(f"✗ {file.name}")
            for e in errori:
                print(f"    {e}")
        else:
            print(f"✓ {file.name}")
            schede.append(scheda)

    print(f"\n{len(schede)} valide, {falliti} con errori")
    if falliti:
        sys.exit(1)
    if args.build:
        # Le foto scaricate da scripts/immagini.py portano autore e licenza.
        crediti = json.loads(CREDITI.read_text(encoding="utf-8")) if CREDITI.exists() else {}
        for scheda in schede:
            scheda["immagini"] = crediti.get(scheda["id"], [])
        out = args.out.resolve()
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps({"schema_version": 1, "piante": schede},
                                  ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        print(f"Scritto {out}")


if __name__ == "__main__":
    main()
