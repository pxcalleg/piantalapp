# App PiantalAPP (Flutter)

App Android che mostra le schede di `dati/piante/`.

- Le schede sono incluse in `assets/piante.json`, quindi l'app funziona offline.
- All'avvio, e quando trascini giù l'elenco, scarica la versione aggiornata da
  `app/assets/piante.json` sul ramo `main` e la salva nel telefono.
- `assets/piante.json` si rigenera da solo su `main` a ogni modifica delle
  schede. In locale: `python scripts/valida.py --build --out app/assets/piante.json`.

## Sviluppo

```bash
cd app
flutter pub get
flutter test
flutter run            # con un telefono collegato o un emulatore
flutter build apk      # APK installabile
```

A ogni pull request che tocca `app/`, GitHub Actions esegue i test e costruisce
un APK scaricabile dalla pagina dell'esecuzione (sezione "Artifacts").

## Struttura

```
lib/main.dart                   avvio e tema
lib/modello/pianta.dart         la scheda pianta (rispecchia lo schema JSON)
lib/modello/filtri.dart         ricerca e filtri rapidi
lib/modello/etichette.dart      testi italiani per i valori codificati
lib/dati/archivio_piante.dart   caricamento offline e aggiornamento da GitHub
lib/schermate/                  elenco, scheda, informazioni
```
