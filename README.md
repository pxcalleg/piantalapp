<img src="grafica/logo-512.png" width="96" alt="Logo di PiantalAPP">

# PiantalAPP

Un database aperto di schede per la cura di piante e fiori, e un'app Android
che lo rende consultabile anche offline.

Ogni scheda spiega come annaffiare, concimare ed esporre una pianta, quanta luce
vuole, se sta in casa, fuori o in un terrarium. I contenuti sono scritti e
revisionati da una comunità di appassionati ed esperti.

## Struttura

```
dati/piante/        una scheda YAML per pianta (contenuti, CC BY-SA 4.0)
schema/             schema JSON che ogni scheda deve rispettare
scripts/valida.py   validazione e generazione di dist/piante.json
.github/            validazione automatica delle pull request e modelli
app/                app Flutter (vedi app/README.md)
grafica/            logo e immagini per lo store
ARCHITETTURA.md     scelte tecniche e piano di lavoro
```

## Piante presenti

| Pianta | Nome scientifico | Dove |
|---|---|---|
| Ficus benjamina | *Ficus benjamina* | appartamento |
| Ficus robusta | *Ficus elastica* | appartamento |
| Ficus lyrata | *Ficus lyrata* | appartamento |
| Pothos | *Epipremnum aureum* | appartamento, ricadente |
| Sansevieria | *Dracaena trifasciata* | appartamento, succulenta |
| Fittonia | *Fittonia albivenis* | terrarium, appartamento |
| Spatifillo | *Spathiphyllum wallisii* | appartamento, fiorita |

## iPhone e iPad

- **Subito, senza App Store:** apri https://pxcalleg.github.io/piantalapp/ con
  Safari, tocca *Condividi* e poi *Aggiungi alla schermata Home*. PiantalAPP
  compare tra le app con la sua icona e si apre a schermo intero.
- **App vera e propria:** il progetto iOS è in `app/ios` e GitHub lo compila a
  ogni modifica (controllo *App iOS*). Per installarla sugli iPhone serve:
  1. un account [Apple Developer](https://developer.apple.com/programs/)
     (99 € l'anno, a nome di una persona o di un'azienda);
  2. registrare l'identificativo `io.github.pxcalleg.piantalapp` e creare
     l'app su [App Store Connect](https://appstoreconnect.apple.com);
  3. firmare e caricare la build: da un Mac con Xcode, oppure aggiungendo a
     GitHub le chiavi di App Store Connect perché la carichi da solo su
     TestFlight;
  4. provarla con TestFlight e inviarla alla revisione di Apple.

## Contribuire

Vedi [CONTRIBUTING.md](CONTRIBUTING.md). Non serve saper programmare.

## Licenze

- Codice: [Apache 2.0](LICENSE)
- Contenuti in `dati/`: [CC BY-SA 4.0](dati/LICENSE.md)
- Foto: da Wikimedia Commons, ognuna con la sua licenza libera; autore e licenza
  sono in `app/assets/immagini/crediti.json` e sotto ogni foto nell'app
